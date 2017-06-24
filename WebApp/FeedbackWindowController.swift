//
//  FeedbackWindowController.swift
//  SmartNote
//
//  Created by Deger on 2017/5/13.
//  Copyright © 2017年 Luofei. All rights reserved.
//

import Cocoa
import CloudKit

class FeedbackWindowController: NSWindowController, NSTextViewDelegate {
    @IBOutlet var textView : NSTextView!
    @IBOutlet var bugRadioButton : NSButton!
    @IBOutlet var suggestRadioButton : NSButton!
    @IBOutlet var submitButton : NSButton!
    @IBOutlet var contactTextField : NSTextField!
    
    
    @IBAction func onBugRadioButtonAction(_ sender : Any) {
        self.suggestRadioButton.state = 0
        self.bugRadioButton.state = 1
    }
    
    @IBAction func onSuggestRadioButtonAction(_ sender : Any) {
        self.suggestRadioButton.state = 1
        self.bugRadioButton.state = 0
    }
    
    @IBAction func onSubmitButtonAction(_ sender : Any) {
        let publicDB = CKContainer.default().publicCloudDatabase
        let feedbackRecord = CKRecord(recordType: "Feedback")
        feedbackRecord.setValue(self.bugRadioButton.state, forKey: "isBug")
        feedbackRecord.setValue(self.textView.string, forKey: "content")
        feedbackRecord.setValue(self.contactTextField.stringValue, forKey: "contact")
        if let dic = Bundle.main.infoDictionary,
            let version = dic["CFBundleShortVersionString"] as? String {
            feedbackRecord.setValue(version, forKey: "version")
        }
        
        publicDB.save(feedbackRecord) { (record, error) in
            if let error = error {
                print(error)
            }
        }
        self.window?.close()
    }
    
    
    func textDidChange(_ notification: Notification) {
        if let string = self.textView.string {
            let nsString = string as NSString
            self.submitButton.isEnabled = nsString.length > 5
        } else {
            self.submitButton.isEnabled = false
        }
    }
    
}
