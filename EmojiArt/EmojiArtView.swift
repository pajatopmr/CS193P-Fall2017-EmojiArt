//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Paul Michael Reilly on 6/17/18.
//  Copyright © 2018 Paul Michael Reilly. All rights reserved.
//

import UIKit

// ADDED AFTER LECTURE 14
// this is the delegate protocol for EmojiArtView
// EmojiArtView wants to be able to let people
// (usually its Controller)
// know when its contents have changed
// but MVC does not allow it to have a pointer to its Controller
// it must communicate "blind and structured"
// this is the "structure" for such communication
// see the delegate var in EmojiArtView below
// note that this protocol can only be implemented by a class
// (not a struct or enum)
// that's because the var with this type is going to be weak
// (to avoid memory cycles)
// and weak implies it's in the heap
// and that implies its a reference type (i.e. a class)

protocol EmojiArtViewDelegate: class {
    func emojiArtViewDidChange(_ sender: EmojiArtView)
}

extension Notification.Name {
    static let EmojiArtViewDidChange = Notification.Name("EmojiArtViewDidChange")
}

class EmojiArtView: UIView, UIDropInteractionDelegate
{
    // MARK: - Delegation

    // ADDED AFTER LECTURE 14
    // if a Controller wants to find out when things change
    // in this EmojiArtView
    // the Controller has to sign up to be the EmojiArtView's delegate
    // then it can have methods in that protocol invoked on it
    // this delegate is notified every time something changes
    // (see uses of this delegate var below and in EmojiArtView+Gestures.swift)
    // this var is weak so that it does not create a memory cycle
    // (i.e. the Controller points to its View and its View points back)
    weak var delegate: EmojiArtViewDelegate?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        addInteraction(UIDropInteraction(delegate: self))
    }

    private var font: UIFont {
        return
            UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(64.0))

    }

    // MARK: - UIDropInteractionDelegate

    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSAttributedString.self) { providers in
            let dropPoint = session.location(in: self)
            for attributedString in providers as? [NSAttributedString] ?? [] {
                self.addLabel(with: attributedString, centeredAt: dropPoint)
                self.delegate?.emojiArtViewDidChange(self) // ADDED AFTER L14
                NotificationCenter.default.post(name: .EmojiArtViewDidChange, object: self)
            }
        }
    }

    // Provide support for leveraging KVO to better handle document
    // change notifications by adding a variable to manage the
    // observer, adding code to addLabel() to track the changes, and
    // adding a handler to free up the heap if and when the subview
    // leaves the heap.

    private var labelObservations = [UIView:NSKeyValueObservation]()

    func addLabel(with attributedString: NSAttributedString, centeredAt point: CGPoint) {
        let label = UILabel()
        label.backgroundColor = .clear
        label.attributedText = attributedString.font != nil ? attributedString : NSAttributedString(string: attributedString.string,attributes: [.font:self.font])
        //     label.attributedText = attributedText
        label.sizeToFit()
        label.center = point
        addEmojiArtGestureRecognizers(to: label)
        addSubview(label)

        // Using KVO, watch the label for a changed value in which case notifications need to get handled.
        labelObservations[label] = label.observe(\.center) { (label, change) in
            self.delegate?.emojiArtViewDidChange(self) // ADDED AFTER L14
            NotificationCenter.default.post(name: .EmojiArtViewDidChange, object: self)
        }
    }

    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        if labelObservations[subview] != nil {
            labelObservations[subview] = nil
        }
    }

    // MARK: - Drawing the Background

    var backgroundImage: UIImage? { didSet { setNeedsDisplay() } }

    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }
}
