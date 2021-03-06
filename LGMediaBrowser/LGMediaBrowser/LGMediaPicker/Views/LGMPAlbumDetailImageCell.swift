//
//  LGMPAlbumDetailImageCell.swift
//  LGMediaBrowser
//
//  Created by 龚杰洪 on 2018/6/26.
//  Copyright © 2018年 龚杰洪. All rights reserved.
//

import UIKit
import Photos
import LGWebImage

/// 组装按钮状态变化时候的bounce动画
///
/// - Returns: 组装好的CAKeyframeAnimation
func buttonStatusChangedAnimation() -> CAKeyframeAnimation {
    let animation = CAKeyframeAnimation(keyPath: "transform")
    animation.duration = 0.3
    animation.isRemovedOnCompletion = true
    animation.fillMode = CAMediaTimingFillMode.forwards
    
    animation.values = [CATransform3DMakeScale(0.7, 0.7, 1.0),
                        CATransform3DMakeScale(1.2, 1.2, 1.0),
                        CATransform3DMakeScale(0.8, 0.8, 1.0),
                        CATransform3DMakeScale(1.0, 1.0, 1.0)]
    return animation
}

/// 显示普通图片和视频缩略图的CELL
public class LGMPAlbumDetailImageCell: UICollectionViewCell {
    /// 显示缩略图的视图
    lazy var layoutImageView: LGAnimatedImageView = {
        let tempImageView = LGAnimatedImageView(frame: self.contentView.bounds)
        tempImageView.contentMode = UIView.ContentMode.scaleAspectFill
        tempImageView.clipsToBounds = true
        return tempImageView
    }()
    
    /// 选择当前图片或视频的操作按钮
    lazy var selectButton: LGClickAreaButton = {
        let tempButton = LGClickAreaButton(type: UIButton.ButtonType.custom)
        tempButton.frame = CGRect(x: self.contentView.lg_width - 26.0, y: 5, width: 23.0, height: 23.0)
        tempButton.setBackgroundImage(UIImage(namedFromThisBundle: "button_unselected"), for: UIControl.State.normal)
        tempButton.setBackgroundImage(UIImage(namedFromThisBundle: "button_selected"), for: UIControl.State.selected)
        tempButton.addTarget(self, action: #selector(selectButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        tempButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        tempButton.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        tempButton.enlargeOffset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 0)
        return tempButton
    }()
    
    /// 视频和LivePhoto标记的背景视图
    lazy var markBgView: LGPlayToolGradientView = {
        let temp = LGPlayToolGradientView(frame: CGRect(x: 0,
                                                        y: self.contentView.lg_height - 20.0,
                                                        width: self.contentView.lg_width,
                                                        height: 20.0))
        return temp
    }()
    
    /// 视频和LivePhoto的类型icon标记视图
    lazy var typeMarkView: UIImageView = {
        let temp = UIImageView(frame: CGRect(x: 5,
                                             y: 2.5,
                                             width: 15.0,
                                             height: 15.0))
        temp.image = UIImage(namedFromThisBundle: "mark_video")
        return temp
    }()
    
    /// 视频长度或者LivePhoto标记Label
    lazy var timeOrTypeMarkLabel: UILabel = {
        let temp = UILabel(frame: CGRect(x: 25.0,
                                         y: 0.0,
                                         width: self.contentView.lg_width - 30.0,
                                         height: 20.0))
        temp.textAlignment = NSTextAlignment.right
        temp.font = UIFont.systemFont(ofSize: 13.0)
        temp.textColor = UIColor(named: "TimeOrTypeMarkLabelText", in: Bundle.this, compatibleWith: nil)
        return temp
    }()
    
    /// 选中遮罩
    lazy var coverView: UIView = {
        let temp = UIView(frame: self.contentView.bounds)
        temp.backgroundColor = maskColor
        temp.isUserInteractionEnabled = false
        temp.isHidden = !isShowMask
        return temp
    }()
    
    /// 圆角大小，默认无圆角
    public var cornerRadius: CGFloat = 0.0
    
    /// 需要被显示的对象
    public var listModel: LGAlbumAssetModel? {
        didSet {
            refreshLayoutIfNeeded()
        }
    }
    
    /// 遮罩背景色
    public var maskColor: UIColor = UIColor.black.withAlphaComponent(0.2)
    
    /// 是否允许选择动图
    public var allowSelectAnimatedImage: Bool = true
    
    /// 是否允许选择LivePhoto
    public var allowSelectLivePhoto: Bool = true
    
    /// 是否显示选择当前视频或图像的按钮
    public var isShowSelectButton: Bool = true
    
    /// 是否显示遮罩
    public var isShowMask: Bool = false
    
    /// 选择按钮点击回调
    public var selectedBlock: ((Bool) -> Void)?
    
    /// 请求图像的请求ID
    private var imageRequestID: PHImageRequestID = PHInvalidImageRequestID
    
    /// 对应图像的标记
    private var identifier: String?
    
    // MARK: -  初始化
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaultViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDefaultViews()
    }
    
    // MARK: -  选择按钮点击事件处理
    @objc func selectButtonPressed(_ button: UIButton) {
        if !button.isSelected {
            button.layer.add(buttonStatusChangedAnimation(), forKey: nil)
        }
        
        if let selectedBlock = self.selectedBlock {
            selectedBlock(button.isSelected)
        }
    }
    
    // MARK: -  加载视图
    
    func setupDefaultViews() {
        self.contentView.addSubview(layoutImageView)
        
        if isShowSelectButton {
            self.contentView.addSubview(selectButton)
        }
        
        self.contentView.addSubview(markBgView)
        markBgView.addSubview(typeMarkView)
        markBgView.addSubview(timeOrTypeMarkLabel)
        
        if isShowMask {
            self.contentView.addSubview(coverView)
        }
    }
    
    // MARK: -  修正视图坐标
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layoutImageView.frame = self.bounds
        
        if isShowSelectButton {
            self.selectButton.frame = CGRect(x: self.contentView.lg_width - 26.0, y: 5, width: 23.0, height: 23.0)
        }
        
        if isShowMask {
            self.coverView.frame = self.bounds
            self.contentView.bringSubviewToFront(self.coverView)
        }
        
        self.markBgView.frame = CGRect(x: 0,
                                       y: self.contentView.lg_height - 20.0,
                                       width: self.contentView.lg_width,
                                       height: 20.0)
        
        self.typeMarkView.frame = CGRect(x: 5, y: 2.5, width: 15.0, height: 15.0)
        self.timeOrTypeMarkLabel.frame = CGRect(x: 25.0,
                                                y: 0.0,
                                                width: self.contentView.lg_width - 30.0,
                                                height: 20.0)
    }
    
    // MARK: -  设置model后刷新显示
    func refreshLayoutIfNeeded() {
        guard let model = self.listModel else { return }
        
        if self.cornerRadius > 0.0 {
            self.layer.cornerRadius = self.cornerRadius
            self.layer.masksToBounds = true
        }
        
        switch model.type {
        case .video:
            self.markBgView.isHidden = false
            self.typeMarkView.isHidden = false
            self.timeOrTypeMarkLabel.isHidden = false
            self.typeMarkView.image = UIImage(namedFromThisBundle: "mark_video")
            self.timeOrTypeMarkLabel.text = model.duration
            break
        case .livePhoto:
            self.markBgView.isHidden = false
            self.typeMarkView.isHidden = false
            self.timeOrTypeMarkLabel.isHidden = false
            self.typeMarkView.image = UIImage(namedFromThisBundle: "mark_livePhoto")
            self.timeOrTypeMarkLabel.text = LGLocalizedString("Live")
            break
        case .image:
            self.markBgView.isHidden = true
            break
        case .animatedImage:
            self.markBgView.isHidden = false
            self.typeMarkView.isHidden = false
            self.timeOrTypeMarkLabel.isHidden = false
            self.typeMarkView.image = nil
            self.timeOrTypeMarkLabel.text = LGLocalizedString("GIF")
            break
        default:
            self.markBgView.isHidden = true
            break
        }
        
        if self.isShowMask {
            self.coverView.backgroundColor = self.maskColor
            self.coverView.isHidden = !model.isSelected
        }
        
        self.selectButton.isHidden = !self.isShowSelectButton
        self.selectButton.isEnabled = self.isShowSelectButton
        self.selectButton.isSelected = model.isSelected
        if model.currentSelectedIndex == -1 {
            self.selectButton.setTitle(nil, for: UIControl.State.normal)
        } else {
            self.selectButton.setTitle("\(model.currentSelectedIndex)", for: UIControl.State.normal)
        }
        
        let scale = UIScreen.main.scale
        let tempSize = CGSize(width: self.contentView.lg_width * scale, height: self.contentView.lg_height * scale)
        
        LGAssetExportManager.default.cancelImageRequest(self.imageRequestID)
        
        self.identifier = model.asset.localIdentifier
        self.layoutImageView.image = nil
        
        self.imageRequestID = LGAssetExportManager.default.requestImage(forAsset: model.asset,
                                                                        outputSize: tempSize,
                                                                        isAsync: true,
                                                                        isNetworkAccessAllowed: false,
                                                                        resizeMode: .fast,
                                                                        completion:
            { [weak self] (resultImage, infoDic) in
                guard let weakSelf = self else { return }
                if weakSelf.identifier == model.asset.localIdentifier {
                    weakSelf.layoutImageView.image = resultImage
                    weakSelf.imageRequestID = PHInvalidImageRequestID
                }
        })
    }
    
}
