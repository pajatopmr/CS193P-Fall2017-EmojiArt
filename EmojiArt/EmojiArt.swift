//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Paul Michael Reilly on 6/26/18.
//  Copyright © 2018 Paul Michael Reilly. All rights reserved.
//

import UIKit

// ADDED AFTER LECTURE 14
//
// This is the delegate protocol for EmojiArtView. EmojiArtView wants
// to be able to let people (usually its Controller) know when its
// contents have changed but MVC does not allow it to have a pointer
// to its Controller. It must communicate "blind and structured". This
// is the "structure" for such communication. See the delegate var in
// EmojiArtView below. Note that this protocol can only be implemented
// by a class (not a struct or enum). That's because the var with this
// type is going to be weak (to avoid memory cycles) and weak implies
// it's in the heap and that implies its a reference type (i.e. a
// class).

protocol EmojiArtViewDelegate: class {
    func emojiArtViewDidChange(_ sender: EmojiArtView)
}

class EmojiArtView: UIView, UIDropInteractionDelegate
{
    // MARK: - Delegation

    // ADDED AFTER LECTURE 14
    //
    // If a Controller wants to find out when things change in this
    // EmojiArtView the Controller has to sign up to be the
    // EmojiArtView's delegate.  Then it can have methods in that
    // protocol invoked on it.  This delegate is notified every time
    // something changes (see uses of this delegate var below and in
    // EmojiArtView+Gestures.swift).  This var is weak so that it does
    // not create a memory cycle (i.e. the Controller points to its
    // View and its View points back).
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
            }
        }
    }

    func addLabel(with attributedString: NSAttributedString, centeredAt point: CGPoint) {
        let label = UILabel()
        label.backgroundColor = .clear
        label.attributedText = attributedString.font != nil ? attributedString : NSAttributedString(string: attributedString.string,attributes: [.font:self.font])
        //     label.attributedText = attributedText
        label.sizeToFit()
        label.center = point
        addEmojiArtGestureRecognizers(to: label)
        addSubview(label)
    }

    // MARK: - Drawing the Background

    var backgroundImage: UIImage? { didSet { setNeedsDisplay() } }

    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }
}
