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
    var onStrokeBegan: (() -> Void)?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        onStrokeBegan?()
    }
}

class DrawViewController: UIViewController, PKCanvasViewDelegate {

    private let canvas = StrokeAwareCanvasView()
    private let toolPicker = PKToolPicker()

    var bgImage: UIImage? = nil
    var bgImageFrame: CGRect? = nil
    var onDrawingExported: ((UIImage, CGRect) -> Void)?

    private var history: [PKDrawing] = [PKDrawing()]
    private var index: Int = 0
    private var isRestoring = false
    private var blockHistoryUntilGestureBegan = false

    private lazy var backButton = makeButton("返回")
    private lazy var undoButton = makeButton("上一步")
    private lazy var redoButton = makeButton("下一步")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        canvas.frame = bgImageFrame ?? .zero
        canvas.backgroundColor = .clear
        canvas.delegate = self
        canvas.alwaysBounceHorizontal = false
        canvas.alwaysBounceVertical = false
        view.addSubview(canvas)

        canvas.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: bgImageFrame?.width ?? 300, height: bgImageFrame?.height ?? 400))
        }

        // Buttons
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

        DispatchQueue.main.async {
            if let window = self.view.window ?? UIApplication.shared.windows.first {
                self.toolPicker.setVisible(true, forFirstResponder: self.canvas)
                self.toolPicker.addObserver(self.canvas)
                self.canvas.becomeFirstResponder()
            }
        }

        canvas.onStrokeBegan = { [weak self] in
            guard let self = self else { return }
            if self.blockHistoryUntilGestureBegan {
                if self.index < self.history.count - 1 {
                    self.history = Array(self.history.prefix(self.index + 1))
                }
                self.blockHistoryUntilGestureBegan = false
            }
        }
    }
    
    private func updateUndoRedoButtonState() {
        undoButton.isEnabled = index > 0
        redoButton.isEnabled = index < history.count - 1

        undoButton.alpha = undoButton.isEnabled ? 1.0 : 0.5
        redoButton.alpha = redoButton.isEnabled ? 1.0 : 0.5
    }
    
    // MARK: - PKCanvasViewDelegate
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        if isRestoring || blockHistoryUntilGestureBegan {
            return
        }

        let current = canvasView.drawing
        let last = history[index]
        if current.dataRepresentation() == last.dataRepresentation() { return }

        history.append(current)
        index += 1
        updateUndoRedoButtonState()

    }

    // MARK: - Undo / Redo
    @objc private func onClickUndo(_ sender: UIButton) {
        guard index > 0 else { return }
        index -= 1
        restore(history[index])
        updateUndoRedoButtonState()

    }

    @objc private func onClickRedo(_ sender: UIButton) {
        guard index < history.count - 1 else { return }
        index += 1
        restore(history[index])
        updateUndoRedoButtonState()

    }

    private func restore(_ drawing: PKDrawing) {
        var newDrawing = PKDrawing()
        for stroke in drawing.strokes {
            newDrawing.strokes.append(stroke)
        }
        isRestoring = true
        canvas.drawing = newDrawing
        canvas.undoManager?.removeAllActions()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isRestoring = false
            self.blockHistoryUntilGestureBegan = true
            self.updateUndoRedoButtonState()
        }
    }


    // MARK: - Export
    @objc private func onClickBack(_ sender: UIButton) {
        guard let (img, rect) = canvas.drawing.exportTrimmedImageWithFrame() else {
            dismiss(animated: true)
            return
        }
        onDrawingExported?(img, rect)
        dismiss(animated: true)
    }

    private func makeButton(_ title: String) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 4
        return btn
    }
}

extension PKDrawing {
    func exportTrimmedImageWithFrame(scale: CGFloat = UIScreen.main.scale) -> (image: UIImage, rect: CGRect)? {
        guard !strokes.isEmpty else { return nil }
        var drawingBounds = CGRect.null
        for stroke in strokes {
            drawingBounds = drawingBounds.union(stroke.renderBounds)
        }
        let padding: CGFloat = 4
        drawingBounds = drawingBounds.insetBy(dx: -padding, dy: -padding)
        let img = self.image(from: drawingBounds, scale: scale)
        return (img, drawingBounds)
    }
}
