//
//  DocumentInfoViewController.swift
//  EmojiArt
//
//  Created by Paul Michael Reilly on 7/6/18.
//  Copyright © 2018 Paul Michael Reilly. All rights reserved.
//

import UIKit

class DocumentInfoViewController: UIViewController
{
    // Add the document model.
    var document: EmojiArtDocument? {
        didSet { updateUI() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    // Update the UI by updating the thumbnail image and the size and creation labels ensuring the document is well
    // formed in the process.
    private func updateUI() {
        
        // Provide a procedural abstraction to handle the size and creation label updates.
        func updateLabels() {
            
            // Provide an encapsulated, inelegant date formatter to help show the creation label.
            let shortDateFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                return formatter
            }()

            if sizeLabel != nil, createdLabel != nil, let url = document?.fileURL,
                let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) {
                sizeLabel.text = "\(attributes[.size] ?? 0) bytes"
                if let created = attributes[.creationDate] as? Date {
                    createdLabel.text = shortDateFormatter.string(from: created)
                }
            }
        }
        
        // Provide a procedural abstraction to handle the thumnail image update. It consists of two parts: 1) updating
        // the image and 2) updating the aspect ratio constraint.
        func updateThumbnailImage() {
            if thumbnailImageView != nil, thumbnailAspectRatio != nil, let thumbnail = document?.thumbnail {
                // Update the image.
                thumbnailImageView.image = thumbnail
                
                // Update the aspect ratio constraint by removing the existing one and adding a new one.
                thumbnailImageView.removeConstraint(thumbnailAspectRatio)
                thumbnailAspectRatio = NSLayoutConstraint(
                    item: thumbnailImageView,
                    attribute: .width,
                    relatedBy: .equal,
                    toItem: thumbnailImageView,
                    attribute: .height,
                    multiplier: thumbnail.size.width / thumbnail.size.height,
                    constant: 0
                )
                thumbnailImageView.addConstraint(thumbnailAspectRatio)
            }
        }

        // Do the work using the procedural abstractions.
        updateLabels()
        updateThumbnailImage()
    }

    // Wire up the thumbnail image (with aspect ratio), size and creation labels.
    @IBOutlet weak var thumbnailAspectRatio: NSLayoutConstraint!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    
    // Provide a handler for the done button to have the presenting controller dismiss us.
    @IBAction func done() {
        presentingViewController?.dismiss(animated: true)
    }
}
