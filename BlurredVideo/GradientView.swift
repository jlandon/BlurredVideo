//
//  GradientView.swift
//
//  Created by Jonathan Landon on 2/3/16.
//
// The MIT License (MIT)
//
// Copyright (c) 2014-2016 Oven Bits, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

/**
 GradientView is a UIView whose contents is simply a linear gradient (CAGradientLayer) of two or more colors.
 
 The class is @IBDesignable with the important properties @IBInspectable.
 */
@IBDesignable
public final class GradientView: UIView {
    
    public enum Direction {
        /// Left-to-Right ➡️
        case horizontal
        /// Bottom-to-Top ⬆️
        case vertical
        /// Bottom-Left-to-Top-Right ↗️
        case ascending
        /// Top-Left-to-Bottom-Right ↘️
        case descending
        /// Custom direction
        case custom(CGPoint, CGPoint)
        
        /**
         Initializer to create a Direction from two points.
         
         - parameter startPoint: The starting point.
         - parameter endPoint: The ending point.
         
         - returns: A Direction object, initialized with a start and end point.
         */
        public init(startPoint: CGPoint, endPoint: CGPoint) {
            switch (startPoint.x, startPoint.y, endPoint.x, endPoint.y) {
            case (0, 0.5, 1, 0.5):
                self = .horizontal
            case (0.5, 1, 0.5, 0):
                self = .vertical
            case (0, 1, 1, 0):
                self = .ascending
            case (0, 0, 1, 1):
                self = .descending
            default:
                self = .custom(startPoint, endPoint)
            }
        }
        
        /// The start point of the direction
        public var startPoint: CGPoint {
            switch self {
            case .horizontal:
                return CGPoint(x: 0, y: 0.5)
            case .vertical:
                return CGPoint(x: 0.5, y: 1)
            case .ascending:
                return CGPoint(x: 0, y: 1)
            case .descending:
                return .zero
            case .custom(let startPoint, _):
                return startPoint
            }
        }
        
        /// The end point of the direction
        public var endPoint: CGPoint {
            switch self {
            case .horizontal:
                return CGPoint(x: 1, y: 0.5)
            case .vertical:
                return CGPoint(x: 0.5, y: 0)
            case .ascending:
                return CGPoint(x: 1, y: 0)
            case .descending:
                return CGPoint(x: 1, y: 1)
            case .custom(_, let endPoint):
                return endPoint
            }
        }
    }
    
    /// The colors to use for the gradient.
    public var colors: [UIColor] = [] {
        didSet {
            updateGradient()
        }
    }
    
    /// The locations to use for the gradient.
    public var locations: [CGFloat]? {
        didSet {
            updateGradient()
        }
    }
    
    /// The direction in which to draw the gradient.
    public var direction: Direction = .horizontal {
        didSet {
            updateGradient()
        }
    }
    
    /// The start color of the gradient (defaults to `.blackColor()`).
    @IBInspectable dynamic private var startColor: UIColor = .black {
        didSet {
            colors = [startColor, endColor]
            updateGradient()
        }
    }
    
    /// The end color of the gradient (defaults to `.whiteColor()`).
    @IBInspectable dynamic private var endColor: UIColor = .white {
        didSet {
            colors = [startColor, endColor]
            updateGradient()
        }
    }
    
    /// The start location of the gradient (defaults to 0).
    @IBInspectable dynamic private var startLocation: CGFloat = 0 {
        didSet {
            locations = [startLocation, endLocation]
            updateGradient()
        }
    }
    
    /// The end location of the gradient (defaults to 1).
    @IBInspectable dynamic private var endLocation: CGFloat = 1 {
        didSet {
            locations = [startLocation, endLocation]
            updateGradient()
        }
    }
    
    /// The start point of the gradient (defaults to `.zero`).
    @IBInspectable dynamic private var startPoint: CGPoint = Direction.horizontal.startPoint {
        didSet {
            direction = Direction(startPoint: startPoint, endPoint: endPoint)
            updateGradient()
        }
    }
    
    /// The end point of the gradient (defaults to `CGPoint(x: 1, y: 1)`).
    @IBInspectable dynamic private var endPoint: CGPoint = Direction.horizontal.endPoint {
        didSet {
            direction = Direction(startPoint: startPoint, endPoint: endPoint)
            updateGradient()
        }
    }
    
    /**
     Initializer to create a GradientView with an array of colors.
     
     - parameter colors: An array of colors to use for the gradient.
     - parameter direction: The direction of the gradient (optional, defaults to `.Horizontal`)
     
     - returns: An instance of GradientView, initialized with an array of colors, and an optional direction.
     */
    public convenience init(colors: [UIColor], direction: Direction = .horizontal) {
        self.init(frame: .zero)
        
        self.colors = colors
        self.direction = direction
    }
    
    public override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateGradient()
    }
    
    public override func prepareForInterfaceBuilder() {
        updateGradient()
    }
    
    /// Update the gradient.
    private func updateGradient() {
        guard let gradient = layer as? CAGradientLayer, !colors.isEmpty else { return }
        
        gradient.startPoint = direction.startPoint
        gradient.endPoint   = direction.endPoint
        
        if colors.count == 1 {
            gradient.locations = locations?.map { NSNumber(value: Float($0)) }
            gradient.colors = [colors[0].cgColor, colors[0].cgColor]
        }
        else {
            gradient.locations = locations?.map { NSNumber(value: Float($0)) }
            gradient.colors    = colors.map { $0.cgColor }
        }
    }
}
