//
//  HKTimeSlider.swift
//  HookMemory
//
//  Created by HF on 2023/11/17.
//

import UIKit

class HKTimeSlider: UISlider {
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let r = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        let x = r.origin.x - 10
        let t = CGRect(x: x, y: 1, width: 30, height: 30)
        return t
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let p = CGPoint(x: 0, y: 14)
        let h: CGFloat = 4
        let b = CGRect(origin: p, size: CGSize(width: bounds.size.width, height: h))
        super.trackRect(forBounds: b)
        return b
    }
}
