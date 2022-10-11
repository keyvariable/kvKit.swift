//===----------------------------------------------------------------------===//
//
//  Copyright (c) 2021 Svyatoslav Popov.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
//  the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
//  specific language governing permissions and limitations under the License.
//
//  SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//
//  KvTransform.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 20.09.2022.
//

// MARK: - KvTransform2

/// Transformation of vectors in 2D coordinate space.
public struct KvTransform2<Math : KvMathScope> {

    public typealias Math = Math

    public typealias Scalar = Math.Scalar
    public typealias Matrix = Math.Matrix3x3
    public typealias NormalMatrix = Math.Matrix2x2

    public typealias Vector = Math.Vector2



    public let matrix: Matrix
    public let inverseMatrix: Matrix

    public let normalMatrix: NormalMatrix



    /// Initializes identity transformation.
    @inlinable
    public init() {
        self.matrix = .identity
        self.inverseMatrix = .identity
        self.normalMatrix = .identity
    }


    @inlinable public init(_ matrix: Matrix) { self.init(matrix, inverseMatrix: matrix.inverse) }

    @inlinable
    public init(_ matrix: Matrix, inverseMatrix: Matrix) {
        self.init(matrix, inverseMatrix, KvAffineTransform2<Math>.normalizeScaleComponent(Math.make2(inverseMatrix).transpose))
    }

    @usableFromInline
    internal init(_ matrix: Matrix, _ inverseMatrix: Matrix, _ normalMatrix: NormalMatrix) {
        self.matrix = matrix
        self.inverseMatrix = inverseMatrix
        self.normalMatrix = normalMatrix

#if DEBUG
        assert()
#endif // DEBUG
    }


    @inlinable
    public init(_ t: KvAffineTransform2<Math>) {
        self.init(Math.make3(t.matrix), Math.make3(t.inverseMatrix), t.normalMatrix)
    }


    /// Initializes a rotation transformation.
    @inlinable
    public init(angle: Scalar) {
        let (sine, cosine) = Math.sincos(angle)

        self.init(
            Matrix(Matrix.Column( cosine, sine, 0),
                   Matrix.Column(-sine, cosine, 0),
                   Matrix.Column.unitZ),
            inverseMatrix: Matrix(Matrix.Column(cosine, -sine, 0),
                                  Matrix.Column( sine, cosine, 0),
                                  Matrix.Column.unitZ)
        )
    }


    /// Initializes product of rotation and scale transformations.
    @inlinable
    public init(angle: Scalar, scale: Vector) {
        let scale⁻¹ = Matrix.Column(Math.recip(scale), 1)
        let (sine, cosine) = Math.sincos(angle)

        self.init(
            Matrix(Matrix.Column( cosine, sine, 0) * scale.x,
                   Matrix.Column(-sine, cosine, 0) * scale.y,
                   Matrix.Column.unitZ),
            inverseMatrix: Matrix(Matrix.Column(cosine, -sine, 0) * scale⁻¹,
                                  Matrix.Column( sine, cosine, 0) * scale⁻¹,
                                  Matrix.Column.unitZ)
        )
    }

    /// Initializes product of rotation and scale transformations.
    @inlinable public init(angle: Scalar, scale: Scalar) { self.init(angle: angle, scale: Vector(repeating: scale)) }


    /// Initializes a scale transformation.
    @inlinable
    public init(scale: Vector) {
        let scale⁻¹ = Math.recip(scale)

        self.init(
            Matrix(diagonal: Matrix.Diagonal(scale, 1)),
            Matrix(diagonal: Matrix.Diagonal(scale⁻¹, 1)),
            NormalMatrix(diagonal: Math.normalize(scale⁻¹))
        )
    }

    /// Initializes a scale transformation.
    @inlinable public init(scale: Scalar) { self.init(scale: Vector(repeating: scale)) }


    /// Initializes a translation transformation.
    @inlinable
    public init(translation: Vector) {
        self.init(
            Matrix(Matrix.Column.unitX,
                   Matrix.Column.unitY,
                   Matrix.Column(translation, 1)),
            Matrix(Matrix.Column.unitX,
                   Matrix.Column.unitY,
                   Matrix.Column(-translation, 1)),
            .identity
        )
    }


    /// Initializes product of translation and rotation transformations.
    @inlinable
    public init(translation: Vector, angle: Scalar) {
        let r = NormalMatrix(angle: angle)
        let r⁻¹ = r.transpose
        let t⁻¹ = -translation

        self.init(
            Matrix(Math.make3(r[0]),
                   Math.make3(r[1]),
                   Matrix.Column(translation, 1)),
            Matrix(Math.make3(r⁻¹[0]),
                   Math.make3(r⁻¹[1]),
                   Matrix.Column(Math.dot(r[0], t⁻¹), Math.dot(r[1], t⁻¹), 1)),
            r
        )
    }


    /// Initializes product of translation, rotation and scale transformations.
    @inlinable
    public init(translation: Vector, angle: Scalar, scale: Vector) {
        var r = NormalMatrix(angle: angle)
        var r⁻¹ = r.transpose

        let scale⁻¹ = Math.recip(scale)
        let t⁻¹ = -translation

        r[0] *= scale.x
        r[1] *= scale.y

        r⁻¹[0] *= scale⁻¹
        r⁻¹[1] *= scale⁻¹

        self.init(
            Matrix(Math.make3(r[0]),
                   Math.make3(r[1]),
                   Matrix.Column(translation, 1)),
            inverseMatrix: Matrix(Math.make3(r⁻¹[0]),
                                  Math.make3(r⁻¹[1]),
                                  Matrix.Column(Math.dot(r[0], t⁻¹), Math.dot(r[1], t⁻¹), 1))
        )
    }

    /// Initializes product of translation, rotation and scale transformations.
    @inlinable
    public init(translation: Vector, angle: Scalar, scale: Scalar) {
        self.init(translation: translation, angle: angle, scale: Vector(repeating: scale))
    }


    /// Initializes product of translation and scale transformations.
    @inlinable
    public init(translation: Vector, scale: Vector) {
        let scale⁻¹ = Math.recip(scale)

        self.init(
            Matrix(Matrix.Column(scale.x, 0, 0),
                   Matrix.Column(0, scale.y, 0),
                   Matrix.Column(translation, 1)),
            Matrix(Matrix.Column(scale⁻¹.x, 0, 0),
                   Matrix.Column(0, scale⁻¹.y, 0),
                   Matrix.Column(-translation * scale⁻¹, 1)),
            NormalMatrix(diagonal: Math.normalize(scale⁻¹))
        )
    }

    /// Initializes product of translation and scale transformations.
    @inlinable
    public init(translation: Vector, scale: Scalar) { self.init(translation: translation, scale: Vector(repeating: scale)) }



    // MARK: Auxiliaries

    @inlinable public static var identity: Self { .init() }


    /// - Returns: Scale component of given tranform matrix.
    ///
    /// - Warning: Assuming bottom row of the matrix is `[ 0, 0, 1 ]`.
    /// - Note: If determinant of the matrix is negative then X scale element is negative and other elements are non-negative.
    @inlinable
    public static func scale(from m: Matrix) -> Vector {
        Vector(x: Math.length(m[0]) * (KvIsNotNegative(m.determinant) ? 1 : -1),
               y: Math.length(m[1]))
    }


    /// - Returns: Transformed coordinate by a transformation represented as given matrix.
    @inlinable
    public static func act(_ matrix: Matrix, coordinate c: Vector) -> Vector {
        let c3 = matrix * Matrix.Column(c, 1)
        return Math.make2(c3) / c3.z
    }


    /// - Returns: Transformed vector by a transformation represented as given matrix.
    @inlinable
    public static func act(_ matrix: Matrix, vector v: Vector) -> Vector {
        Math.make2(matrix * Math.make3(v))
    }



    // MARK: Operations

    /// Transformed X basis vector.
    @inlinable public var basisX: Vector { Math.make2(matrix[0]) }
    /// Transformed Y basis vector.
    @inlinable public var basisY: Vector { Math.make2(matrix[1]) }


    /// A boolean value indicating whether the receiver is numerically equal to identity tranformation.
    @inlinable public var isIdentity: Bool { Math.isEqual(matrix, .identity) }


    /// The inverse transform.
    @inlinable
    public var inverse: Self {
        Self(inverseMatrix, matrix, KvAffineTransform2<Math>.normalizeScaleComponent(Math.make2(matrix).transpose))
    }


    /// Scale component of the receiver.
    ///
    /// - Warning: Assuming bottom row of the receiver's matrix is `[ 0, 0, 1 ]`.
    /// - Note: If determinant of the matrix is negative then X scale element is negative and other elements are non-negative.
    @inlinable public var scale: Vector { KvTransform2.scale(from: matrix) }

    /// Translation component of the receiver.
    ///
    /// - Warning: Assuming bottom row of the receiver's matrix is `[ 0, 0, 1 ]`.
    @inlinable public var translation: Vector { Math.make2(matrix[2]) }


    /// - Returns: Tranformed normal.
    @inlinable public func act(normal n: Vector) -> Vector { normalMatrix * n }

    /// - Returns: Transformed coordinate.
    @inlinable public func act(coordinate c: Vector) -> Vector { KvTransform2.act(matrix, coordinate: c) }

    /// - Returns: Transformed vector.
    @inlinable public func act(vector v: Vector) -> Vector { KvTransform2.act(matrix, vector: v) }


#if DEBUG
    /// Performs various validations and calls *assertionFailure()* if the receiver is not valid.
    @inlinable
    public func assert() {
        Swift.assert(Math.isEqual(matrix * inverseMatrix, .identity), "The matrix and it's inverse don't match")
        Swift.assert(Math.isEqual(KvAffineTransform2<Math>.normalizeScaleComponent(Math.make2(inverseMatrix).transpose), normalMatrix), "The matrix and the normal matrix don't match")
    }
#endif // DEBUG


    /// Fast implementation for product of the tranlation and the receiver.
    @inlinable
    public func translated(by translation: Vector) -> Self {
        var m = matrix
        var m⁻¹ = inverseMatrix
        let t3 = Math.make3(translation)

        m[2] += t3
        // - Note: Assuming bottom row of m⁻¹ is [ 0, 0, 1 ]
        m⁻¹[2] -= m⁻¹ * t3

        return Self(m, m⁻¹, normalMatrix)
    }



    // MARK: Operators

    @inlinable
    public static func *(lhs: Self, rhs: Self) -> Self {
        Self(lhs.matrix * rhs.matrix, inverseMatrix: rhs.inverseMatrix * lhs.inverseMatrix)
    }

    @inlinable
    public static func *(lhs: Self, rhs: Vector) -> Vector { lhs.act(vector: rhs) }

}


// MARK: : KvNumericallyEquatable

extension KvTransform2 : KvNumericallyEquatable {

    /// - Returns: A boolean value indicating whether the receiver and *rhs* are numerically equal.
    @inlinable public func isEqual(to rhs: Self) -> Bool { Math.isEqual(matrix, rhs.matrix) }

}


// MARK: : Equatable

extension KvTransform2 : Equatable {

    @inlinable public static func ==(lhs: Self, rhs: Self) -> Bool { lhs.matrix == rhs.matrix }

    @inlinable public static func !=(lhs: Self, rhs: Self) -> Bool { lhs.matrix != rhs.matrix }

}



// MARK: - KvAffineTransform2

/// Affine transformation of vectors in 2D coordinate space.
public struct KvAffineTransform2<Math : KvMathScope> {

    public typealias Math = Math

    public typealias Scalar = Math.Scalar
    public typealias Matrix = Math.Matrix2x2
    public typealias NormalMatrix = Math.Matrix2x2

    public typealias Vector = Math.Vector2



    public let matrix: Matrix
    public let inverseMatrix: Matrix

    public let normalMatrix: NormalMatrix



    /// Initializes identity transformation.
    @inlinable
    public init() {
        self.matrix = .identity
        self.inverseMatrix = .identity
        self.normalMatrix = .identity
    }


    @inlinable public init(_ matrix: Matrix) { self.init(matrix, inverseMatrix: matrix.inverse) }

    @inlinable
    public init(_ matrix: Matrix, inverseMatrix: Matrix) {
        self.init(matrix, inverseMatrix, KvAffineTransform2.normalizeScaleComponent(inverseMatrix.transpose))
    }

    @usableFromInline
    internal init(_ matrix: Matrix, _ inverseMatrix: Matrix, _ normalMatrix: NormalMatrix) {
        self.matrix = matrix
        self.inverseMatrix = inverseMatrix
        self.normalMatrix = normalMatrix

#if DEBUG
        assert()
#endif // DEBUG
    }


    /// Initializes a rotation transformation.
    @inlinable
    public init(angle: Scalar) {
        let r = Matrix(angle: angle)
        let r⁻¹ = r.transpose

        self.init(r, r⁻¹, r)
    }


    /// Initializes product of rotation and scale transformations.
    @inlinable
    public init(angle: Scalar, scale: Vector) {
        let scale⁻¹ = Math.recip(scale)

        var m = Matrix(angle: angle)
        var m⁻¹ = m.transpose

        m[0] *= scale.x
        m[1] *= scale.y

        m⁻¹[0] *= scale⁻¹
        m⁻¹[1] *= scale⁻¹

        self.init(m, inverseMatrix: m⁻¹)
    }

    /// Initializes product of rotation and scale transformations.
    @inlinable public init(angle: Scalar, scale: Scalar) { self.init(angle: angle, scale: Vector(repeating: scale)) }


    /// Initializes a scale transformation.
    @inlinable
    public init(scale: Vector) {
        let scale⁻¹ = Math.recip(scale)

        self.init(Matrix(diagonal: scale), Matrix(diagonal: scale⁻¹), NormalMatrix(diagonal: Math.normalize(scale⁻¹)))
    }

    /// Initializes a scale transformation.
    @inlinable public init(scale: Scalar) { self.init(scale: Vector(repeating: scale)) }



    // MARK: Auxiliaries

    @inlinable public static var identity: Self { .init() }


    /// - Returns: Scale component of given affine tranform matrix.
    ///
    /// - Note: If determinant of the matrix is negative then X scale element is negative and other elements are non-negative.
    @inlinable
    public static func scale(from m: Matrix) -> Vector {
        Vector(x: Math.length(m[0]) * (KvIsNotNegative(m.determinant) ? 1 : -1),
               y: Math.length(m[1]))
    }


    /// - Returns: Matrix produced from *m* by normalization of the scale component.
    ///
    /// - Note: This method is to normal matrices to compensate for the effect on length of normals.
    @inlinable
    public static func normalizeScaleComponent(_ m: Matrix) -> Matrix {
        m * Math.rsqrt(0.5 * (Math.length²(m[0]) + Math.length²(m[1])))
    }



    // MARK: Operations

    /// Transformed X basis vector.
    @inlinable public var basisX: Vector { matrix[0] }
    /// Transformed Y basis vector.
    @inlinable public var basisY: Vector { matrix[1] }


    /// A boolean value indicating whether the receiver is numerically equal to identity tranformation.
    @inlinable public var isIdentity: Bool { Math.isEqual(matrix, .identity) }


    /// The inverse transform.
    @inlinable public var inverse: Self { Self(inverseMatrix, matrix, Self.normalizeScaleComponent(matrix.transpose)) }


    /// Scale component of the receiver.
    ///
    /// - Note: If determinant of the matrix is negative then X scale element is negative and other elements are non-negative.
    @inlinable public var scale: Vector { Self.scale(from: matrix) }


    /// - Returns: Tranformed normal.
    @inlinable public func act(normal n: Vector) -> Vector { normalMatrix * n }

    /// - Returns: Transformed coordinate.
    @inlinable public func act(coordinate c: Vector) -> Vector { act(vector: c) }

    /// - Returns: Transformed vector.
    @inlinable public func act(vector v: Vector) -> Vector { matrix * v }


#if DEBUG
    /// Performs various validations and calls *assertionFailure()* if the receiver is not valid.
    @inlinable
    public func assert() {
        Swift.assert(Math.isEqual(matrix * inverseMatrix, .identity), "The matrix and it's inverse don't match")
        Swift.assert(Math.isEqual(Self.normalizeScaleComponent(inverseMatrix.transpose), normalMatrix), "The matrix and the normal matrix don't match")
    }
#endif // DEBUG



    // MARK: Operators

    @inlinable
    public static func *(lhs: Self, rhs: Self) -> Self {
        Self(lhs.matrix * rhs.matrix, inverseMatrix: rhs.inverseMatrix * lhs.inverseMatrix)
    }

    @inlinable
    public static func *(lhs: Self, rhs: Vector) -> Vector { lhs.act(vector: rhs) }

}


// MARK: : KvNumericallyEquatable

extension KvAffineTransform2 : KvNumericallyEquatable {

    /// - Returns: A boolean value indicating whether the receiver and *rhs* are numerically equal.
    @inlinable public func isEqual(to rhs: Self) -> Bool { Math.isEqual(matrix, rhs.matrix) }

}


// MARK: : Equatable

extension KvAffineTransform2 : Equatable {

    @inlinable public static func ==(lhs: Self, rhs: Self) -> Bool { lhs.matrix == rhs.matrix }

    @inlinable public static func !=(lhs: Self, rhs: Self) -> Bool { lhs.matrix != rhs.matrix }

}



// MARK: - KvTransform3

/// Transformation of vectors in 3D coordinate space.
public struct KvTransform3<Math : KvMathScope> {

    public typealias Math = Math

    public typealias Scalar = Math.Scalar
    public typealias Matrix = Math.Matrix4x4
    public typealias NormalMatrix = Math.Matrix3x3

    public typealias Vector = Math.Vector3



    public let matrix: Matrix
    public let inverseMatrix: Matrix

    public let normalMatrix: NormalMatrix



    /// Initializes identity transformation.
    @inlinable
    public init() {
        self.matrix = .identity
        self.inverseMatrix = .identity
        self.normalMatrix = .identity
    }


    @inlinable public init(_ matrix: Matrix) { self.init(matrix, inverseMatrix: matrix.inverse) }

    @inlinable
    public init(_ matrix: Matrix, inverseMatrix: Matrix) {
        self.init(matrix, inverseMatrix, KvAffineTransform3<Math>.normalizeScaleComponent(Math.make3(inverseMatrix).transpose))
    }

    @usableFromInline
    internal init(_ matrix: Matrix, _ inverseMatrix: Matrix, _ normalMatrix: NormalMatrix) {
        self.matrix = matrix
        self.inverseMatrix = inverseMatrix
        self.normalMatrix = normalMatrix

#if DEBUG
        assert()
#endif // DEBUG
    }


    @inlinable
    public init(_ t: KvAffineTransform3<Math>) {
        self.init(Math.make4(t.matrix), Math.make4(t.inverseMatrix), t.normalMatrix)
    }


    /// Initializes a rotation transformation.
    @inlinable
    public init(quaternion: Math.Quaternion) {
        let r = Matrix(quaternion)

        self.init(r, inverseMatrix: r.transpose)
    }


    /// Initializes product of rotation and scale transformations.
    @inlinable
    public init(quaternion: Math.Quaternion, scale: Vector) {
        let scale⁻¹ = Matrix.Column(Math.recip(scale), 1)

        var m = Matrix(quaternion)
        var m⁻¹ = m.transpose

        m[0] *= scale.x
        m[1] *= scale.y
        m[2] *= scale.z

        m⁻¹[0] *= scale⁻¹
        m⁻¹[1] *= scale⁻¹
        m⁻¹[2] *= scale⁻¹

        self.init(m, inverseMatrix: m⁻¹)
    }

    /// Initializes product of rotation and scale transformations.
    @inlinable public init(quaternion: Math.Quaternion, scale: Scalar) { self.init(quaternion: quaternion, scale: Vector(repeating: scale)) }


    /// Initializes a scale transformation.
    @inlinable
    public init(scale: Vector) {
        let scale⁻¹ = Math.recip(scale)

        self.init(
            Matrix(diagonal: Matrix.Diagonal(scale, 1)),
            Matrix(diagonal: Matrix.Diagonal(scale⁻¹, 1)),
            NormalMatrix(diagonal: Math.normalize(scale⁻¹))
        )
    }

    /// Initializes a scale transformation.
    @inlinable public init(scale: Scalar) { self.init(scale: Vector(repeating: scale)) }


    /// Initializes a translation transformation.
    @inlinable
    public init(translation: Vector) {
        self.init(
            Matrix(.unitX,
                   .unitY,
                   .unitZ,
                   Matrix.Column(translation, 1)),
            Matrix(.unitX,
                   .unitY,
                   .unitZ,
                   Matrix.Column(-translation, 1)),
            .identity
        )
    }


    /// Initializes product of translation and rotation transformations.
    @inlinable
    public init(translation: Vector, quaternion: Math.Quaternion) {
        let r = NormalMatrix(quaternion)
        let r⁻¹ = r.transpose
        let t⁻¹ = -translation

        self.init(
            Matrix(Math.make4(r[0]),
                   Math.make4(r[1]),
                   Math.make4(r[2]),
                   Matrix.Column(translation, 1)),
            Matrix(Math.make4(r⁻¹[0]),
                   Math.make4(r⁻¹[1]),
                   Math.make4(r⁻¹[2]),
                   Matrix.Column(Math.dot(r[0], t⁻¹), Math.dot(r[1], t⁻¹), Math.dot(r[2], t⁻¹), 1)),
            r
        )
    }


    /// Initializes product of translation, rotation and scale transformations.
    @inlinable
    public init(translation: Vector, quaternion: Math.Quaternion, scale: Vector) {
        var r = NormalMatrix(quaternion)
        var r⁻¹ = r.transpose

        let scale⁻¹ = Math.recip(scale)
        let t⁻¹ = -translation

        r[0] *= scale.x
        r[1] *= scale.y
        r[2] *= scale.z

        r⁻¹[0] *= scale⁻¹
        r⁻¹[1] *= scale⁻¹
        r⁻¹[2] *= scale⁻¹

        self.init(
            Matrix(Math.make4(r[0]),
                   Math.make4(r[1]),
                   Math.make4(r[2]),
                   Matrix.Column(translation, 1)),
            inverseMatrix: Matrix(Math.make4(r⁻¹[0]),
                                  Math.make4(r⁻¹[1]),
                                  Math.make4(r⁻¹[2]),
                                  Matrix.Column(Math.dot(r[0], t⁻¹), Math.dot(r[1], t⁻¹), Math.dot(r[2], t⁻¹), 1))
        )
    }

    /// Initializes product of translation, rotation and scale transformations.
    @inlinable
    public init(translation: Vector, quaternion: Math.Quaternion, scale: Scalar) {
        self.init(translation: translation, quaternion: quaternion, scale: Vector(repeating: scale))
    }


    /// Initializes product of translation and scale transformations.
    @inlinable
    public init(translation: Vector, scale: Vector) {
        let scale⁻¹ = Math.recip(scale)

        self.init(
            Matrix(Matrix.Column(scale.x, 0, 0, 0),
                   Matrix.Column(0, scale.y, 0, 0),
                   Matrix.Column(0, 0, scale.z, 0),
                   Matrix.Column(translation, 1)),
            Matrix(Matrix.Column(scale⁻¹.x, 0, 0, 0),
                   Matrix.Column(0, scale⁻¹.y, 0, 0),
                   Matrix.Column(0, 0, scale⁻¹.z, 0),
                   Matrix.Column(-translation * scale⁻¹, 1)),
            NormalMatrix(diagonal: Math.normalize(scale⁻¹))
        )
    }

    /// Initializes product of translation and scale transformations.
    @inlinable
    public init(translation: Vector, scale: Scalar) { self.init(translation: translation, scale: Vector(repeating: scale)) }



    // MARK: Auxiliaries

    @inlinable public static var identity: Self { .init() }


    /// - Returns: Scale component of given tranform matrix.
    ///
    /// - Warning: Assuming bottom row of the matrix is `[ 0, 0, 0, 1 ]`.
    /// - Note: If determinant of the matrix is negative then X scale element is negative and other elements are non-negative.
    @inlinable
    public static func scale(from m: Matrix) -> Vector {
        Vector(x: Math.length(m[0]) * (KvIsNotNegative(m.determinant) ? 1 : -1),
               y: Math.length(m[1]),
               z: Math.length(m[2]))
    }


    /// - Returns: Transformed coordinate by a transformation represented as given matrix.
    @inlinable
    public static func act(_ matrix: Matrix, coordinate c: Vector) -> Vector {
        let c4 = matrix * Matrix.Column(c, 1)
        return Math.make3(c4) / c4.w
    }


    /// - Returns: Transformed vector by a transformation represented as given matrix.
    @inlinable
    public static func act(_ matrix: Matrix, vector v: Vector) -> Vector {
        Math.make3(matrix * Math.make4(v))
    }



    // MARK: Projections

    /// - Returns: Matrix of standard orthogonal projection.
    @inlinable
    public static func orthogonalProjection(left: Scalar, right: Scalar, top: Scalar, bottom: Scalar, near: Scalar, far: Scalar) -> Matrix {
        Matrix(diagonal: Math.recip(Matrix.Diagonal(left - right, bottom - top, near - far, 1)))
        * Matrix([ -2,  0, 0, 0 ],
                 [  0, -2, 0, 0 ],
                 [  0,  0, 2, 0 ],
                 Matrix.Column(right + left, top + bottom, far + near, 1))
    }


    /// - Parameter aspect: Ratio of Viewport width to viewport height.
    /// - Parameter fof: Vertical camera angle.
    ///
    /// - Returns: Projection matrix for a centered rectangular pinhole camera.
    @inlinable
    public static func perspectiveProjection(aspect: Scalar, fov: Scalar, near: Scalar, far: Scalar) -> Matrix {
        let tg = Math.tan(0.5 * fov)

        return (Matrix(diagonal: Math.recip(Matrix.Diagonal(aspect * tg, tg, near - far, 1)))
                * Matrix(Matrix.Column.unitX,
                         Matrix.Column.unitY,
                         Matrix.Column(0,  0,  (far + near)  , -1),
                         Matrix.Column(0,  0,  2 * far * near,  0)))
    }


    /// - Parameter k: Calibration matrix K (intrinsic matrix) of pinhole camera.
    ///
    /// - Returns: Projective matrix for pinhole camera.
    ///
    /// - Note: The perspective projection matrix is a combination of orthogonal projection matrix in the frame image units and the camera projective matrix.
    /// - Note: See details [here](http://ksimek.github.io/2013/06/03/calibrated_cameras_in_opengl/).
    @inlinable
    public static func projectiveCameraMatrix(k: Math.Matrix3x3, near: Scalar, far: Scalar) -> Matrix {
        // - Note: Implementation below uses full K matrix. It seems better then picking some elements if K.
        Matrix(.unitX, .unitY, .unitW, .unitZ)
        * Matrix(Matrix.Column(k[0], 0),
                 Matrix.Column(k[1], 0),
                 Matrix.Column(-k[2], near + far),
                 Matrix.Column(0, 0, 0, near * far))
    }



    // MARK: Operations

    /// Transformed X basis vector.
    @inlinable public var basisX: Vector { Math.make3(matrix[0]) }
    /// Transformed Y basis vector.
    @inlinable public var basisY: Vector { Math.make3(matrix[1]) }
    /// Transformed Z basis vector.
    @inlinable public var basisZ: Vector { Math.make3(matrix[2]) }


    /// A boolean value indicating whether the receiver is numerically equal to identity tranformation.
    @inlinable public var isIdentity: Bool { Math.isEqual(matrix, .identity) }


    /// The inverse transform.
    @inlinable
    public var inverse: Self {
        Self(inverseMatrix, matrix, KvAffineTransform3<Math>.normalizeScaleComponent(Math.make3(matrix).transpose))
    }


    /// Scale component of the receiver.
    ///
    /// - Warning: Assuming bottom row of the matrix is `[ 0, 0, 0, 1 ]`.
    /// - Note: If determinant of the matrix is negative then X scale element is negative and other elements are non-negative.
    @inlinable public var scale: Vector { KvTransform3.scale(from: matrix) }

    /// Translation component of the receiver.
    ///
    /// - Warning: Assuming bottom row of the receiver's matrix is `[ 0, 0, 0, 1 ]`.
    @inlinable public var translation: Vector { Math.make3(matrix[2]) }


    /// - Returns: Tranformed normal.
    @inlinable public func act(normal n: Vector) -> Vector { normalMatrix * n }

    /// - Returns: Transformed coordinate.
    @inlinable public func act(coordinate c: Vector) -> Vector { KvTransform3.act(matrix, coordinate: c) }

    /// - Returns: Transformed vector.
    @inlinable public func act(vector v: Vector) -> Vector { KvTransform3.act(matrix, vector: v) }


#if DEBUG
    /// Performs various validations and calls *assertionFailure()* if the receiver is not valid.
    @inlinable
    public func assert() {
        Swift.assert(Math.isEqual(matrix * inverseMatrix, .identity), "The matrix and it's inverse don't match")
        Swift.assert(Math.isEqual(KvAffineTransform3<Math>.normalizeScaleComponent(Math.make3(inverseMatrix).transpose), normalMatrix), "The matrix and the normal matrix don't match")
    }
#endif // DEBUG


    /// Fast implementation for product of the tranlation and the receiver.
    @inlinable
    public func translated(by translation: Vector) -> Self {
        var m = matrix
        var m⁻¹ = inverseMatrix
        let t4 = Math.make4(translation)

        m[3] += t4
        // - Note: Assuming bottom row of m⁻¹ is [ 0, 0, 1 ]
        m⁻¹[3] -= m⁻¹ * t4

        return Self(m, m⁻¹, normalMatrix)
    }



    // MARK: Operators

    @inlinable
    public static func *(lhs: Self, rhs: Self) -> Self {
        Self(lhs.matrix * rhs.matrix, inverseMatrix: rhs.inverseMatrix * lhs.inverseMatrix)
    }

    @inlinable
    public static func *(lhs: Self, rhs: Vector) -> Vector { lhs.act(vector: rhs) }

}


// MARK: : KvNumericallyEquatable

extension KvTransform3 : KvNumericallyEquatable {

    /// - Returns: A boolean value indicating whether the receiver and *rhs* are numerically equal.
    @inlinable public func isEqual(to rhs: Self) -> Bool { Math.isEqual(matrix, rhs.matrix) }

}


// MARK: : Equatable

extension KvTransform3 : Equatable {

    @inlinable public static func ==(lhs: Self, rhs: Self) -> Bool { lhs.matrix == rhs.matrix }

    @inlinable public static func !=(lhs: Self, rhs: Self) -> Bool { lhs.matrix != rhs.matrix }

}



// MARK: - KvAffineTransform3

/// Affine transformation of vectors in 3D coordinate space.
public struct KvAffineTransform3<Math : KvMathScope> {

    public typealias Math = Math

    public typealias Scalar = Math.Scalar
    public typealias Matrix = Math.Matrix3x3
    public typealias NormalMatrix = Math.Matrix3x3

    public typealias Vector = Math.Vector3



    public let matrix: Matrix
    public let inverseMatrix: Matrix

    public let normalMatrix: NormalMatrix



    /// Initializes identity transformation.
    @inlinable
    public init() {
        self.matrix = .identity
        self.inverseMatrix = .identity
        self.normalMatrix = .identity
    }


    @inlinable public init(_ matrix: Matrix) { self.init(matrix, inverseMatrix: matrix.inverse) }

    @inlinable
    public init(_ matrix: Matrix, inverseMatrix: Matrix) {
        self.init(matrix, inverseMatrix, KvAffineTransform3.normalizeScaleComponent(inverseMatrix.transpose))
    }

    @usableFromInline
    internal init(_ matrix: Matrix, _ inverseMatrix: Matrix, _ normalMatrix: NormalMatrix) {
        self.matrix = matrix
        self.inverseMatrix = inverseMatrix
        self.normalMatrix = normalMatrix

#if DEBUG
        assert()
#endif // DEBUG
    }


    /// Initializes a rotation transformation.
    @inlinable
    public init(quaternion: Math.Quaternion) {
        let r = Matrix(quaternion)

        self.init(r, r.transpose, r)
    }


    /// Initializes product of rotation and scale transformations.
    @inlinable
    public init(quaternion: Math.Quaternion, scale: Vector) {
        let scale⁻¹ = Math.recip(scale)

        var m = Matrix(quaternion)
        var m⁻¹ = m.transpose

        m[0] *= scale.x
        m[1] *= scale.y
        m[2] *= scale.z

        m⁻¹[0] *= scale⁻¹
        m⁻¹[1] *= scale⁻¹
        m⁻¹[2] *= scale⁻¹

        self.init(m, inverseMatrix: m⁻¹)
    }

    /// Initializes product of rotation and scale transformations.
    @inlinable public init(quaternion: Math.Quaternion, scale: Scalar) { self.init(quaternion: quaternion, scale: Vector(repeating: scale)) }


    /// Initializes a scale transformation.
    @inlinable
    public init(scale: Vector) {
        let scale⁻¹ = Math.recip(scale)

        self.init(Matrix(diagonal: scale), Matrix(diagonal: scale⁻¹), NormalMatrix(diagonal: Math.normalize(scale⁻¹)))
    }

    /// Initializes a scale transformation.
    @inlinable public init(scale: Scalar) { self.init(scale: Vector(repeating: scale)) }



    // MARK: Auxiliaries

    @inlinable public static var identity: Self { .init() }


    /// - Returns: Scale component of given tranform matrix.
    ///
    /// - Note: If determinant of the matrix is negative then X scale element is negative and other elements are non-negative.
    @inlinable
    public static func scale(from m: Matrix) -> Vector {
        Vector(x: Math.length(m[0]) * (KvIsNotNegative(m.determinant) ? 1 : -1),
               y: Math.length(m[1]),
               z: Math.length(m[2]))
    }


    /// - Returns: Scale factor applied to given normal matrix to compensate for the effect on length of normals.
    ///
    /// - Note: This method is to normal matrices to compensate for the effect on length of normals.
    @inlinable
    public static func normalizeScaleComponent(_ m: Matrix) -> Matrix {
        m * Math.rsqrt((Math.length²(m[0]) + Math.length²(m[1]) + Math.length²(m[2])) * ((1.0 as Scalar) / (3.0 as Scalar)))
    }



    // MARK: Operations

    /// Transformed X basis vector.
    @inlinable public var basisX: Vector { matrix[0] }
    /// Transformed Y basis vector.
    @inlinable public var basisY: Vector { matrix[1] }
    /// Transformed Z basis vector.
    @inlinable public var basisZ: Vector { matrix[2] }


    /// A boolean value indicating whether the receiver is numerically equal to identity tranformation.
    @inlinable public var isIdentity: Bool { Math.isEqual(matrix, .identity) }


    /// The inverse transform.
    @inlinable public var inverse: Self { Self(inverseMatrix, matrix, Self.normalizeScaleComponent(matrix.transpose)) }


    /// Scale component of the receiver.
    ///
    /// - Note: If determinant of the matrix is negative then X scale element is negative and other elements are non-negative.
    @inlinable public var scale: Vector { KvAffineTransform3.scale(from: matrix) }


    /// - Returns: Tranformed normal.
    @inlinable public func act(normal n: Vector) -> Vector { normalMatrix * n }

    /// - Returns: Transformed coordinate.
    @inlinable public func act(coordinate c: Vector) -> Vector { act(vector: c) }

    /// - Returns: Transformed vector.
    @inlinable public func act(vector v: Vector) -> Vector { matrix * v }


#if DEBUG
    /// Performs various validations and calls *assertionFailure()* if the receiver is not valid.
    @inlinable
    public func assert() {
        Swift.assert(Math.isEqual(matrix * inverseMatrix, .identity), "The matrix and it's inverse don't match")
        Swift.assert(Math.isEqual(Self.normalizeScaleComponent(inverseMatrix.transpose), normalMatrix), "The matrix and the normal matrix don't match")
    }
#endif // DEBUG



    // MARK: Operators

    @inlinable
    public static func *(lhs: Self, rhs: Self) -> Self {
        Self(lhs.matrix * rhs.matrix, inverseMatrix: rhs.inverseMatrix * lhs.inverseMatrix)
    }

    @inlinable
    public static func *(lhs: Self, rhs: Vector) -> Vector { lhs.act(vector: rhs) }

}


// MARK: : KvNumericallyEquatable

extension KvAffineTransform3 : KvNumericallyEquatable {

    /// - Returns: A boolean value indicating whether the receiver and *rhs* are numerically equal.
    @inlinable public func isEqual(to rhs: Self) -> Bool { Math.isEqual(matrix, rhs.matrix) }

}


// MARK: : Equatable

extension KvAffineTransform3 : Equatable {

    @inlinable public static func ==(lhs: Self, rhs: Self) -> Bool { lhs.matrix == rhs.matrix }

    @inlinable public static func !=(lhs: Self, rhs: Self) -> Bool { lhs.matrix != rhs.matrix }

}
