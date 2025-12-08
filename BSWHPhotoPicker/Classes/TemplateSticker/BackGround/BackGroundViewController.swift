//
//  BackGroundViewController.swift
//  BSWHPhotoPicker
//
//  Created by 笔尚文化 on 2025/12/2.
//

final class BackGroundImageCell: UICollectionViewCell {

    static let reuseId = "BackGroundImageCell"

    private let imgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.layer.cornerRadius = 10
        return img
    }()

    // track what image name is currently loading/assigned to avoid race
    private var currentImageName: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imgView)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imgView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imgView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imgView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // clear image and cancel logical token
        imgView.image = nil
        currentImageName = nil
    }

    /// Set item - async safe
    func setItem(_ item: TemplateModel) {
        // colors or special items handled synchronously (cheap)
        let key = item.imageBg
        currentImageName = key

        if key.hasPrefix("#") {
            imgView.image = kkCommon.imageFromHex(key)
            return
        }

        if key == "BackgroundPicker" {
            // show a placeholder color icon or something
            imgView.image = BSWHBundle.image(named: "BackgroundPicker")
            return
        }

        if key == "BackgroundNoColor" {
            imgView.image = BSWHBundle.image(named: "BackgroundNoColor")
            return
        }

        // try synchronous cache first
        if let cached = BGImageCache.shared.cachedImage(named: key) {
            imgView.image = cached
            return
        }

        // async load/ decode
        BGImageCache.shared.loadImage(named: key) { [weak self] image in
            guard let self = self else { return }
            // ensure still relevant (cell may have been reused)
            if self.currentImageName != key { return }
            self.imgView.image = image
        }
    }
}

// ---------------------------
// MARK: - BackgroundContentCell
// ---------------------------

protocol BackgroundContentCellDelegate: AnyObject {
    func backgroundContentCell(_ cell: BackgroundContentCell, didSelectItem item: TemplateModel, at index: IndexPath)
}

final class BackgroundContentCell: UICollectionViewCell {

    static let reuseId = "BackgroundContentCell"

    weak var delegate: BackgroundContentCellDelegate?

    // store items; only reload inner collection when changed
    var items: [TemplateModel] = [] {
        didSet {
            // compare equality to avoid unnecessary reload
            if oldValue != items {
                innerCollectionView.reloadData()
                // scroll to top for better UX
                innerCollectionView.setContentOffset(.zero, animated: false)
            }
        }
    }

    private lazy var innerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 9

        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = (screenWidth - 24 - 24 - 10*2) / 3 // match your previous math
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.sectionInset = UIEdgeInsets(top: 9, left: 24, bottom: 9, right: 24)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.showsVerticalScrollIndicator = false
        cv.register(BackGroundImageCell.self, forCellWithReuseIdentifier: BackGroundImageCell.reuseId)
        // IMPORTANT: remove prefetch to avoid mass decode when user scrolls
        cv.isPrefetchingEnabled = false
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(innerCollectionView)
        innerCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            innerCollectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            innerCollectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            innerCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            innerCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BackgroundContentCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BackGroundImageCell.reuseId, for: indexPath) as? BackGroundImageCell else {
            return UICollectionViewCell()
        }

        let model = items[indexPath.item]
        cell.setItem(model)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        delegate?.backgroundContentCell(self, didSelectItem: item, at: indexPath)
    }
}

// ---------------------------
// MARK: - BackGroundViewController (optimized, single-file)
// ---------------------------

public class BackGroundViewController: UIViewController, UIScrollViewDelegate {

    private let topView = UIView()
    private lazy var backBtn: UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        iv.image = BSWHBundle.image(named: "templateNavBack")
        let tap = UITapGestureRecognizer(target: self, action: #selector(onBack))
        iv.addGestureRecognizer(tap)
        return iv
    }()

    private lazy var titleLab: UILabel = {
        let l = UILabel()
        l.textColor = kkColorFromHex("333333")
        l.font = UIFont.systemFont(ofSize: 18)
        l.textAlignment = .center
        l.text = BSWHPhotoPickerLocalization.shared.localized("Background")
        return l
    }()

    private let tabView = CustomScrViewList()
    private var collectionView: UICollectionView!

    private var titles: [String] = []
    private var items: [[TemplateModel]] = []

    private var colorItem: TemplateModel?

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.hidden(true)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        StickerManager.shared.templateOrBackground = 2

        titles = ConfigDataItem.getBackgroundTabData()
        items = ConfigDataItem.getBackgroundListData()

        setupTopView()
        setupCollectionView()

        tabView.delegate?.scrViewDidSelect(index: StickerManager.shared.selectedTemplateIndex)
    }

    @objc private func onBack() {
        dismiss(animated: true)
    }

    private func setupTopView() {
        view.addSubview(topView)
        topView.backgroundColor = .white
        topView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topView.leftAnchor.constraint(equalTo: view.leftAnchor),
            topView.rightAnchor.constraint(equalTo: view.rightAnchor),
            topView.topAnchor.constraint(equalTo: view.topAnchor),
            topView.heightAnchor.constraint(equalToConstant: kkNAVIGATION_BAR_HEIGHT + 44)
        ])

        tabView.titles = titles
        tabView.backgroundColor = .white
        tabView.delegate = self
        topView.addSubview(tabView)
        topView.addSubview(backBtn)
        topView.addSubview(titleLab)

        tabView.translatesAutoresizingMaskIntoConstraints = false
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        titleLab.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tabView.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
            tabView.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 24),
            tabView.rightAnchor.constraint(equalTo: topView.rightAnchor),
            tabView.heightAnchor.constraint(equalToConstant: 44),

            backBtn.widthAnchor.constraint(equalToConstant: 24),
            backBtn.heightAnchor.constraint(equalToConstant: 24),
            backBtn.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 12),
            backBtn.bottomAnchor.constraint(equalTo: tabView.topAnchor, constant: -8),

            titleLab.centerYAnchor.constraint(equalTo: backBtn.centerYAnchor),
            titleLab.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            titleLab.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 36),
            titleLab.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -36)
        ])
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: view.bounds.width, height: view.bounds.height - kkNAVIGATION_BAR_HEIGHT - 44)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.register(BackgroundContentCell.self, forCellWithReuseIdentifier: BackgroundContentCell.reuseId)
        cv.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(cv)
        NSLayoutConstraint.activate([
            cv.topAnchor.constraint(equalTo: tabView.bottomAnchor),
            cv.leftAnchor.constraint(equalTo: view.leftAnchor),
            cv.rightAnchor.constraint(equalTo: view.rightAnchor),
            cv.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        collectionView = cv
    }
}

extension BackGroundViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BackgroundContentCell.reuseId, for: indexPath) as? BackgroundContentCell else {
            return UICollectionViewCell()
        }

        // assign items (BackgroundContentCell will only reload if changed)
        if indexPath.item < items.count {
            cell.items = items[indexPath.item]
        } else {
            cell.items = []
        }
        cell.delegate = self
        return cell
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        tabView.selectIndex(index: page, animated: true)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        tabView.selectIndex(index: page, animated: true)
    }
}

extension BackGroundViewController: CustomScrViewListDelegate {
    func scrViewDidSelect(index: Int) {
        collectionView.layoutIfNeeded()
        if let attributes = collectionView.layoutAttributesForItem(at: IndexPath(item: index, section: 0)) {
            collectionView.scrollRectToVisible(attributes.frame, animated: true)
        }
    }
}

extension BackGroundViewController: BackgroundContentCellDelegate {
    func backgroundContentCell(_ cell: BackgroundContentCell, didSelectItem item: TemplateModel, at index: IndexPath) {

        let key = item.imageBg
        if key.hasPrefix("#") {
            guard let img = kkCommon.imageFromHex(key) else { return }
            presentEdit(item: item, image: img)
            return
        }

        if key == "BackgroundNoColor" {
//            let v = UIView()
//            v.frame.size = CGSize(width: 400, height: 400)
//            let img = v.exportTransparentPNG()
//            if let data = img!.pngData() {
//                print("Has transparent pixel:", data.contains(0))
//            }
            let img = BSWHBundle.image(named: "BackgroundNoColor")
            presentEdit(item: item, image: img!)
            return
        }

        if key == "BackgroundPicker" {
            colorItem = item
            let picker = UIColorPickerViewController()
            picker.delegate = self
            picker.supportsAlpha = true
            present(picker, animated: true)
            return
        }

        // try cache sync then async fallback
        if let cached = BGImageCache.shared.cachedImage(named: key) ?? BSWHBundle.image(named: key) {
            presentEdit(item: item, image: cached)
            return
        }

        BGImageCache.shared.loadImage(named: key) { [weak self] image in
            guard let self = self, let img = image else { return }
            self.presentEdit(item: item, image: img)
        }
    }

    private func presentEdit(item: TemplateModel, image: UIImage) {
        let controller = EditImageViewController(image: image)
        controller.item = item
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
}

// ---------------------------
// MARK: - Color Picker
// ---------------------------

extension BackGroundViewController: UIColorPickerViewControllerDelegate {
    public func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        guard let item = colorItem else { return }
        let color = viewController.selectedColor
        let image = UIImage.from(color: color, size: CGSize(width: 400, height: 400))
        viewController.dismiss(animated: false)
        presentEdit(item: item, image: image)
    }
}

