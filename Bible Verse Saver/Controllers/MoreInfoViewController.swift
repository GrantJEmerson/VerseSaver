//
//  MoreInfoViewController.swift
//  Bible Verse Saver
//
//  Created by Grant Emerson on 2/19/17.
//  Copyright © 2017 com.grant-emerson. All rights reserved.
//

import UIKit
import QuartzCore
import AVFoundation
import CoreLocation
import CoreData

class MoreInfoViewController: UIViewController, UITextViewDelegate, AVSpeechSynthesizerDelegate {
    
    // MARK: - Properties
    
    private let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var verse: Verse!
    var reloadDelegate: LoadData!
    
    private lazy var voice = AVSpeechSynthesizer()
    
    private let placeHolderText = "Write what this verse means to you..."
    private var verseString = ""
    
    @IBOutlet weak var speechButton: UIButton!
    @IBOutlet weak var verseNameText: UILabel!
    @IBOutlet weak var actualVerseText: UILabel!
    @IBOutlet weak var verseImportanceText: UITextView!
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if verse.verseImportance != nil {
            verseImportanceText.textColor = .black
            verseImportanceText.text = verse.verseImportance
        }
        
        verseImportanceText.layer.borderWidth = 1
        
        self.actualVerseText.layer.cornerRadius = 20
        self.actualVerseText.layer.borderWidth = 2.0
        self.actualVerseText.layer.borderColor = UIColor.white.cgColor
        self.actualVerseText.clipsToBounds = true
        
        verseNameText.text = verse.verse
        
        guard let selectedVerse = verse.verse else { return }
        
        let twoVerseComponents = selectedVerse.components(separatedBy: ":")
        let verseForURL = twoVerseComponents[1]
        let chapterAndBook = twoVerseComponents[0].components(separatedBy: " ")
        let book = chapterAndBook[0]
        let chapterAndColon = chapterAndBook[1].components(separatedBy: ":")
        let chapter = chapterAndColon[0]
        let newBook = book.replacingOccurrences(of: "_", with: "+")
        
        guard let url = URL(string: "https://www.biblegateway.com/passage/?search=\(newBook)+\(chapter)%3A\(verseForURL)&version=NKJV") else { urlError(); return }
        loadVerseText(withURL: url)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        voice.stopSpeaking(at: .immediate)
    }
    
    // MARK: - IBActions
    
    @IBAction func backToVerses(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func deleteVerse(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Confirm Delete", message: "Do you wish to delete this verse?", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        let deleteAction = UIAlertAction(title: "Confirm", style: .destructive) { (action) in
            self.moc.delete(self.verse)
            
            do {
                try self.moc.save()
            } catch {
                print(error.localizedDescription)
            }
            
            self.reloadDelegate.reloadData()
            self.navigationController?.dismiss(animated: true)
        }
        
        alertController.addAction(deleteAction)
        
        alertController.modalPresentationStyle = .popover
        
        self.present(alertController, animated: true)
    }
    
    @IBAction func speech(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.6,
                       animations: {
                        sender.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }, completion: { _ in
            UIView.animate(withDuration: 0.6) {
                sender.transform = CGAffineTransform.identity
            }
        })
        
        if voice.isSpeaking == true {
            voice.stopSpeaking(at: .immediate)
        } else if actualVerseText.text != "" {
            speak(text: actualVerseText.text!)
        }
    }
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        let stringToShare = "This is a verse I wanted to send to you: \(verse.verse ?? "") - \(verseString)"
        let activityVC = UIActivityViewController(activityItems: [stringToShare], applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad ,
            activityVC.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
                activityVC.popoverPresentationController?.sourceView = self.view
        }
        self.present(activityVC, animated: true)
    }
    
    // MARK: - Private Functions
    
    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string:text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        voice.delegate = self
        voice.speak(utterance)
    }
    
    private func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        verseImportanceText.frame = verseImportanceText.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    private func loadVerseText(withURL url: URL) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data else { self.urlError(); return }
            
            if let error = error {
                print(error.localizedDescription)
                self.urlError()
            } else {
                guard let urlContent = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
                    self.urlError()
                    return
                }
                guard urlContent.contains("<meta property=\"og:description\" content=\"") else {
                    self.verseNotFound()
                    return
                }
                let urlContentArrayForVerse = urlContent.components(separatedBy: "<meta property=\"og:description\" content=\"")
                guard (urlContentArrayForVerse.count > 0) else {
                    self.urlError()
                    return
                }
                var verseArray = urlContentArrayForVerse[1].components(separatedBy: "\"/>")
                DispatchQueue.main.async {
                    self.verseString = verseArray[0] as String
                    self.actualVerseText.text = verseArray[0] as String
                }
                
            }
        }
        task.resume()
    }
    
    private func urlError() {
        DispatchQueue.main.async {
            self.actualVerseText.text = "Verse can not be reached!"
        }
    }
    
    private func verseNotFound() {
        let alertController = UIAlertController(title: "Verse Can Not Be Found!", message: "We will delete this verse from your list.", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { (action) in
            self.moc.delete(self.verse)
            do {
                try self.moc.save()
            } catch {
                print(error.localizedDescription)
            }
            self.navigationController?.popViewController(animated: true)
        })
        
        alertController.modalPresentationStyle = .popover
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    // MARK: - TextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if verseImportanceText.text == placeHolderText {
            verseImportanceText.text = ""
            verseImportanceText.textColor = .black
        }
        
        animateViewMoving(up: true, moveValue:  0.65 * (self.view.bounds
            .midY))
        
        actualVerseText.textColor = UIColor.clear
        verseNameText.textColor = UIColor.clear
        speechButton.isEnabled = false
        speechButton.imageView?.isHidden = true
        actualVerseText.isHidden = true
        
        addKeyboardDismissalRecognizer()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if verseImportanceText.text == "" {
            verseImportanceText.text = placeHolderText
            verseImportanceText.textColor = .lightGray
            verseImportanceText.textAlignment = .center
        }
        
        animateViewMoving(up: false, moveValue: 0.65 * (self.view.bounds
            .midY))
        
        actualVerseText.textColor = UIColor.black
        verseNameText.textColor = UIColor.black
        speechButton.isEnabled = true
        speechButton.imageView?.isHidden = false
        actualVerseText.isHidden = false
        
        verse.verseImportance = verseImportanceText.text
        verse.save()
        
        for recognizer in view.gestureRecognizers! {
            view.removeGestureRecognizer(recognizer)
        }
    }
    
    // MARK: - TextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showMap",
            let navController = segue.destination as? UINavigationController,
            let mapVC = navController.viewControllers[0] as? BibleVerseLocationViewController else { return }
        mapVC.annotationText = verse.verse
        mapVC.coordinate = CLLocationCoordinate2D(latitude: verse.locationLatitude,
                                                  longitude: verse.locationLongitude)
    }
    
}

extension UIViewController {
    
    // MARK: - Keyboard Dismissall Implementation
    
    func addKeyboardDismissalRecognizer() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

