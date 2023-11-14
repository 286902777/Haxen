//
//  HKEmptyView.swift
//  HookMemory
//
//  Created by HF on 2023/11/8.
//  HKEmptyView 不推荐直接使用 通过扩展使用空页面方法 showTableEmpty, dismissEmpty 配对使用

import UIKit

fileprivate var emptyViewKey :Void?

extension UIView {
    /// 展示空页面
    /// - Parameters:
    ///   - image: 空页面图片
    ///   - title: 标题
    ///   - btnTitle: 按钮标题
    ///   - offsetY: 居中后的offsetY
    ///   - tapAction: 空页面点击
    ///   - btnClickAction: 按钮点击
    ///   - updateFrameBlock: 可以通过该方法修正frame 默认frame覆盖在当前view上
    func showEmpty(with image: UIImage?, title: String?, btnTitle: String? = nil, offsetY: CGFloat = 0, tapAction: (()->())?, btnClickAction: (()->())?, updateFrameBlock: ((CGRect, UIView)->(CGRect))? = nil) {
        // 添加新的
        let emptyView = HKEmptyView(image: image, title: title, btnTitle: btnTitle, offsetY:  offsetY, emptyTapAction: tapAction, btnClickAction: btnClickAction)
        self.showEmpty(emptyView, updateFrameBlock: updateFrameBlock)
    }
    
    func showEmpty(_ emptyView: HKEmptyView, updateFrameBlock: ((CGRect, UIView)->(CGRect))? = nil) {
        // 移除旧的
        let empty = objc_getAssociatedObject(self, &emptyViewKey) as? HKEmptyView
        empty?.removeFromSuperview()
        // 添加新的
        self.addSubview(emptyView)
        self.sendSubviewToBack(emptyView)
        
        objc_setAssociatedObject(self, &emptyViewKey, emptyView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        let y: CGFloat = 0
        let height = self.frame.height
        let width = self.frame.width
        var rect = CGRect(x: 0, y: y, width: width, height: height)
        rect = updateFrameBlock?(rect, self) ?? rect
        emptyView.frame = rect
    }
    
    /// 隐藏当前view添加的空页面
    func dismissEmpty() {
        let emptyView = objc_getAssociatedObject(self, &emptyViewKey) as? HKEmptyView
        emptyView?.removeFromSuperview()
        objc_setAssociatedObject(self, &emptyViewKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
protocol EmptyProtocol {
    func showTableEmpty(with image: UIImage?, title: String?, btnTitle: String? , offsetY: CGFloat, tapAction: (()->())?, btnClickAction: (()->())?)
}

extension UITableView: EmptyProtocol {
    
    /// tableView空页面
    /// - Parameters:
    ///   - image: image description
    ///   - title: title description
    ///   - btnTitle: btnTitle description
    ///   - offsetY: offsetY description
    ///   - tapAction: tapAction description
    ///   - btnClickAction: btnClickAction description
    func showTableEmpty(with image: UIImage?, title: String?, btnTitle: String?, offsetY: CGFloat, tapAction: (()->())?, btnClickAction: (()->())?) {
        
        let emptyView = HKEmptyView(image: image, title: title, btnTitle: btnTitle, offsetY: offsetY, emptyTapAction: tapAction, btnClickAction: btnClickAction)
        showTableEmpty(emptyView)
    }
    
    func showTableEmpty(_ emptyView: HKEmptyView, updateFrameBlock: ((CGRect, UIView)->(CGRect))? = nil) {
        
        let block = updateFrameBlock ?? {
            // 自动矫正
            let width = $0.width
            let x: CGFloat = 0
            var y: CGFloat = 0
            var height = $0.height
            
            if let tableV = $1 as? UITableView {
                y += tableV.tableHeaderView?.frame.height ?? 0
                height -= (tableV.tableHeaderView?.frame.height ?? 0) + (tableV.tableFooterView?.frame.height ?? 0)
            }
            return CGRect(x: x, y: y, width: width, height: height)
        }
        showEmpty(emptyView, updateFrameBlock: block)
    }
}

extension UICollectionView: EmptyProtocol {

    /// CollectionView空页面
    /// - Parameters:
    ///   - image: image description
    ///   - title: title description
    ///   - btnTitle: btnTitle description
    ///   - offsetY: offsetY description
    ///   - tapAction: tapAction description
    ///   - btnClickAction: btnClickAction description
    func showTableEmpty(with image: UIImage?, title: String?, btnTitle: String? = nil, offsetY: CGFloat = 0, tapAction: (()->())?, btnClickAction: (()->())?) {
        
        let emptyView = HKEmptyView(image: image, title: title, btnTitle: btnTitle, offsetY:  offsetY, emptyTapAction: tapAction, btnClickAction: btnClickAction)
        showTableEmpty(emptyView)
    }
    
    func showTableEmpty(_ emptyView: HKEmptyView, updateFrameBlock: ((CGRect, UIView)->(CGRect))? = nil) {
        
        let block = updateFrameBlock ?? {
            // 自动矫正
            let width = $0.width
            let x: CGFloat = 0
            var y: CGFloat = 0
            var height = $0.height
            
            if let tableV = $1 as? UITableView {
                y += tableV.tableHeaderView?.frame.height ?? 0
                height -= (tableV.tableHeaderView?.frame.height ?? 0) + (tableV.tableFooterView?.frame.height ?? 0)
            }
            return CGRect(x: x, y: y, width: width, height: height)
        }
        showEmpty(emptyView, updateFrameBlock: block)
    }
}

class HKEmptyView: UIView {
    enum emptyType: Int {
        case noNet = 0
        case noContent
    }
    typealias EmptyViewBottomViewConfig = (BottomView)->()
    
    var bottomViewConfig: EmptyViewBottomViewConfig?
    
    private var kContentSpace: CGFloat = 16
    
    private var kTitleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
    private var kTitleColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    private var kBtnFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    private var kBtnBgColor = #colorLiteral(red: 0.9607843137, green: 0.1294117647, blue: 0.06666666667, alpha: 1)
    private var kBtnTextColor = UIColor.white
    private var kBtnHeight: CGFloat = 36
    private var kMinBtnWidth: CGFloat = 82
    
    private var offsetY: CGFloat = 0
    
    private var type: emptyType = .noNet
    private var image: UIImage? {
        didSet {
            addImageView()
        }
    }
    
    private var title: String? {
        didSet {
            addTitleLbl()
        }
    }
    
    private var btnTitle: String? {
        didSet {
            addBtn()
        }
    }
    
    private var emptyTapAction: (()->())?
    private var btnClickAction: (()->())?
    
    fileprivate init(type: emptyType = .noNet, image: UIImage?, title: String?, btnTitle: String?, offsetY: CGFloat = 0, emptyTapAction: (()->())?, btnClickAction: (()->())?, bottomViewConfig: EmptyViewBottomViewConfig? = nil) {
        
        super.init(frame: .zero)
        self.type = type
        self.image = image
        self.title = title
        self.btnTitle = btnTitle
        self.emptyTapAction = emptyTapAction
        self.btnClickAction = btnClickAction
        self.offsetY = offsetY
        self.bottomViewConfig = bottomViewConfig
        setupSubViews()
    }
    
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = kTitleFont
        lbl.textColor = kTitleColor
        lbl.textAlignment = .center
        return lbl
    }()

    private lazy var bottomView: BottomView = {
        let view = BottomView()
        let btn = view.btn
        btn.titleLabel?.font = kBtnFont
        btn.setTitleColor(kBtnTextColor, for: .normal)
        btn.backgroundColor = kBtnBgColor
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(clickAct), for: .touchUpInside)
        return view
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = kContentSpace
        return stack
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
    }
    
    private func setupSubViews() {
        addSubview(contentStack)
        contentStack.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-offsetY)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
        }
        
        addImageView()
        addTitleLbl()
        addBtn()
        addTapAction()
    }
    
    private func addImageView() {
        if let img = self.image {
            self.imageView.image = img
            
            if contentStack.arrangedSubviews.contains(self.imageView) {
                return
            }
            contentStack.addArrangedSubview(self.imageView)
        }
    }
    
    private func addTitleLbl() {
        if let title = self.title, title.count > 0 {
            self.titleLbl.text = title
            if contentStack.arrangedSubviews.contains(self.titleLbl) {
                return
            }
            contentStack.addArrangedSubview(self.titleLbl)
        }
    }

    private func addBtn() {
        if let btnT = self.btnTitle, btnT.count > 0 {
            
            self.bottomView.btn.setTitle(btnT, for: .normal)
            if contentStack.arrangedSubviews.contains(self.bottomView) {
                return
            }

            contentStack.addArrangedSubview(self.bottomView)
            self.bottomView.btn.sizeToFit()
            if self.bottomView.btn.frame.width < kMinBtnWidth {
                self.bottomView.btn.snp.makeConstraints { (make) in
                    make.width.equalTo(kMinBtnWidth)
                    make.height.equalTo(kBtnHeight)
                }
            }
        }
        if let config = bottomViewConfig {
            config(bottomView)
            contentStack.addArrangedSubview(bottomView)
        }
        
    }
    
    private func addTapAction() {
        if let _ = emptyTapAction {
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
            self.addGestureRecognizer(tap)
        }
        
    }
    
    @objc private func tapAction()  {
        emptyTapAction?()
    }
    
    @objc private func clickAct() {
        btnClickAction?()
    }
    
    
    
    class BottomView: UIView {
//        private var kBtnHeight: CGFloat = 48

//        private var kMinBtnW: CGFloat = 120
        
        lazy var btn: UIButton = {
            let btn = UIButton(type: .custom)
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            return btn
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupSubViews()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupSubViews()
        }
        
        private func setupSubViews() {
            addSubview(btn)
            btn.snp.makeConstraints { (make) in
                make.top.equalTo(24)
                make.bottom.equalToSuperview()
                make.centerX.equalToSuperview()
            }
        }
    }
}

fileprivate let kDefaultEmptyImgName = "placeholder_empty"
fileprivate let kDefaultEmptyTitle = "暂无数据"

extension HKEmptyView {
    // 优惠券
    static func myCouponEmptyView(btnClickBlock: (()->())?) -> HKEmptyView {
        
        let view = HKEmptyView(image: UIImage(named: kDefaultEmptyImgName), title: kDefaultEmptyTitle, btnTitle: nil, offsetY: 0, emptyTapAction: nil) {
            btnClickBlock?()
            print("------------")
        } bottomViewConfig: { (bottomV) in
            let b = bottomV.btn
            b.backgroundColor = .clear
            b.setTitle("查看历史优惠券", for: .normal)
            b.setTitleColor(UIColor.hex("#141414"), for: .normal)
            b.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            b.setImage(UIImage(named: "icon_my_coupon_left"), for: .normal)
            b.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
            
            bottomV.btn.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(20)
                make.height.equalTo(17)
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            
        }
        return view
    }
}

