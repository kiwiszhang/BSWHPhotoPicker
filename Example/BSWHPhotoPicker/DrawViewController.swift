//
//  Widget02ViewController.swift
//  BSWHPhotoPicker_Example
//
//  Created by 笔尚文化 on 2025/11/4.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import PencilKit

class StrokeAwareCanvasView: PKCanvasView {
    var onStrokeEnded: (() -> Void)?

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        onStrokeEnded?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        onStrokeEnded?()
    }
}

class DrawViewController: UIViewController, PKCanvasViewDelegate {

    private let canvas = StrokeAwareCanvasView()
    private var history: [PKDrawing] = [PKDrawing()]
    private var index = 0
    private var isRestoring = false

    let toolPicker = PKToolPicker()

    var bgImage: UIImage? = nil
    var bgImageFrame: CGRect? = nil
    var onDrawingExported: ((UIImage,CGRect) -> Void)?

    // 保存按“笔画”粒度的撤销/重做快照（每个元素都是一个 PKDrawing）
    private var undoStack: [PKDrawing] = []
    private var redoStack: [PKDrawing] = []
    // 用户刚执行完 undo / redo 后的标记
    private var didUndoOrRedo = false

    // 防止程序性赋值导致 delegate 记录
    private var isApplyingProgrammaticChange = false

    // 记录上一次已知 drawing（用于比较 stroke 数量）
    private var lastKnownDrawing: PKDrawing = PKDrawing()

    private var drawingHistory: [PKDrawing] = [PKDrawing()]
    private var currentIndex: Int = 0
    private var isApplyingProgramChange = false


    
    // UI
    private lazy var backButton = makeButton("返回")
    private lazy var undoButton = makeButton("上一步") // 撤销
    private lazy var redoButton = makeButton("下一步") // 重做

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        canvas.frame = bgImageFrame ?? .zero
        canvas.backgroundColor = .clear
        canvas.delegate = self
        canvas.alwaysBounceVertical = false
        canvas.alwaysBounceHorizontal = false
        view.addSubview(canvas)

        canvas.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: bgImageFrame!.width, height: bgImageFrame!.height))
        }

        // 初始快照（保证有一个基础状态）
        lastKnownDrawing = canvas.drawing
        undoStack = []    // 初始状态不放入 undoStack（也可按需要放入）

        // 布局按钮
        view.addSubview(backButton)
        view.addSubview(undoButton)
        view.addSubview(redoButton)

        backButton.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(30)
            make.left.equalToSuperview().offset(8)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
        }
        undoButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        redoButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-8)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }

        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        undoButton.addTarget(self, action: #selector(onClickUndo(_:)), for: .touchUpInside)
        redoButton.addTarget(self, action: #selector(onClickRedo(_:)), for: .touchUpInside)

        // Tool picker（延迟到主线程，确保 window 可用）
        DispatchQueue.main.async {
            if let window = self.view.window ?? UIApplication.shared.windows.first {
                self.toolPicker.setVisible(true, forFirstResponder: self.canvas)
                self.toolPicker.addObserver(self.canvas)
                self.canvas.becomeFirstResponder()
            }
        }

//        updateUndoRedoButtonState()

        (canvas as! StrokeAwareCanvasView).onStrokeEnded = { [weak self] in
            guard let self else { return }
            guard !self.isRestoring else { return } // 避免程序恢复误记

            let current = self.canvas.drawing
            let last = self.history[self.index]

            // 没变化不记录
            if current.dataRepresentation() == last.dataRepresentation() { return }

            // 如果不是最新一步，截断未来分支
            if self.index < self.history.count - 1 {
                self.history.removeLast(self.history.count - self.index - 1)
            }

            self.history.append(current)
            self.index = self.history.count - 1
        }


    }
    // MARK: - PKCanvasViewDelegate
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
//        if isApplyingProgramChange { return }
//
//        let current = canvasView.drawing
//        let last = drawingHistory[currentIndex]
//
//        // 检查是否新增笔画
//        if current.strokes.count != last.strokes.count {
//            // 如果不在最新一步，截断未来
//            if currentIndex < drawingHistory.count - 1 {
//                drawingHistory.removeLast(drawingHistory.count - currentIndex - 1)
//            }
//
//            drawingHistory.append(current)
//            currentIndex = drawingHistory.count - 1
//        }
    }



        // MARK: - Undo / Redo（按笔画粒度）
    @objc private func onClickUndo(_ sender: UIButton) {
        guard index > 0 else { return }
        index -= 1
        restoreDrawing(history[index])
    }

    @objc private func onClickRedo(_ sender: UIButton) {
        guard index < history.count - 1 else { return }
        index += 1
        restoreDrawing(history[index])
    }

    private func restoreDrawing(_ drawing: PKDrawing) {
        isRestoring = true
        canvas.drawing = drawing
        DispatchQueue.main.async { [weak self] in
            self?.isRestoring = false
        }
    }



        // 用来在恢复 drawing 时屏蔽 delegate 的记录
        private func applyDrawingProgrammatically(_ drawing: PKDrawing) {
            isApplyingProgrammaticChange = true
            canvas.drawing = drawing
            // 为了保险起见，把上一次的 lastKnownDrawing 也更新为同一个（delegate 也会早早返回）
            lastKnownDrawing = drawing

            // 使用 dispatch async 确保 delegate 在赋值完成后处理完再取消屏蔽
            DispatchQueue.main.async { [weak self] in
                self?.isApplyingProgrammaticChange = false
            }
        }

        private func updateUndoRedoButtonState() {
            undoButton.isEnabled = !undoStack.isEmpty
            redoButton.isEnabled = !redoStack.isEmpty
            undoButton.alpha = undoButton.isEnabled ? 1.0 : 0.5
            redoButton.alpha = redoButton.isEnabled ? 1.0 : 0.5
        }

        // 其余方法略（按钮构造、返回等）...
        private func makeButton(_ title: String) -> UIButton {
            let btn = UIButton(type: .custom)
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            btn.backgroundColor = .systemBlue
            btn.layer.cornerRadius = 4
            return btn
        }

        @objc private func onClickBack(_ sender: UIButton) {
            guard let (img, rectInCanvas) = canvas.drawing.exportTrimmedImageWithFrame() else {
                dismiss(animated: true)
                return
            }
            let rectInSuperview = canvas.convert(rectInCanvas, to: view.superview)
            let imageView = UIImageView(image: img)
            imageView.frame = rectInSuperview
            imageView.contentMode = .scaleAspectFit
            view.superview?.addSubview(imageView) // 放在上一层视图

            onDrawingExported?(img,rectInCanvas)

            dismiss(animated: false)
        }
    }

extension PKDrawing {
    func exportTrimmedImageWithFrame(scale: CGFloat = UIScreen.main.scale) -> (image: UIImage, rect: CGRect)? {
        guard !strokes.isEmpty else { return nil }

        var drawingBounds = CGRect.null
        for stroke in strokes {
            drawingBounds = drawingBounds.union(stroke.renderBounds)
        }

        // 可选 padding
        let padding: CGFloat = 4
        drawingBounds = drawingBounds.insetBy(dx: -padding, dy: -padding)

        let img = self.image(from: drawingBounds, scale: scale)
        return (img, drawingBounds)
    }
}

