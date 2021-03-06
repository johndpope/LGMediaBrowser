//
//  LGTapDetectingView.swift
//  LGMediaBrowser
//
//  Created by 龚杰洪 on 2018/4/24.
//  Copyright © 2018年 龚杰洪. All rights reserved.
//

import UIKit
import LGWebImage

public protocol LGTapDetectingImageViewDelegate: NSObjectProtocol {
    func singleTapDetected(_ touch: UITouch, targetView: UIImageView)
    func doubleTapDetected(_ touch: UITouch, targetView: UIImageView)
}

open class LGTapDetectingImageView: LGAnimatedImageView, LGMediaPreviewerProtocol {
    public required convenience init(frame: CGRect, mediaModel: LGMediaModel) {
        self.init(frame: frame)
    }
    
    public weak var detectingDelegate: LGTapDetectingImageViewDelegate?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
    }
    
    override public init(image: UIImage?) {
        super.init(image: image)
        self.isUserInteractionEnabled = true
    }
    
    override public init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        self.isUserInteractionEnabled = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = true
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            switch touch.tapCount {
            case 1:
                detectingDelegate?.singleTapDetected(touch, targetView: self)
                break
            case 2:
                detectingDelegate?.doubleTapDetected(touch, targetView: self)
                break
            default:
                break
            }
        }
        self.next?.touchesEnded(touches, with: event)
    }
}
