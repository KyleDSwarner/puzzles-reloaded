//
//  AnimatableTransform.swift
//  Puzzles Reloaded
//
//  A GeometryEffect wrapper around CGAffineTransform that makes
//  it Animatable in SwiftUI by decomposing its 6 components into
//  individual CGFloat properties with VectorArithmetic conformance.
//

import SwiftUI

struct AnimatableTransform: GeometryEffect {
    var a, b, c, d, tx, ty: CGFloat

    init(_ transform: CGAffineTransform) {
        a  = transform.a
        b  = transform.b
        c  = transform.c
        d  = transform.d
        tx = transform.tx
        ty = transform.ty
    }

    init(a: CGFloat, b: CGFloat, c: CGFloat, d: CGFloat, tx: CGFloat, ty: CGFloat) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.tx = tx
        self.ty = ty
    }

    // MARK: - Animatable

    var animatableData: AnimatablePair<
        CGFloat,
        AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>>>>
    > {
        get {
            .init(a, .init(b, .init(c, .init(d, .init(tx, ty)))))
        }
        set {
            a  = newValue.first
            b  = newValue.second.first
            c  = newValue.second.second.first
            d  = newValue.second.second.second.first
            tx = newValue.second.second.second.second.first
            ty = newValue.second.second.second.second.second
        }
    }

    // MARK: - GeometryEffect

    func effectValue(size: CGSize) -> ProjectionTransform {
        let t = CGAffineTransform(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
        return ProjectionTransform(t)
    }
}
