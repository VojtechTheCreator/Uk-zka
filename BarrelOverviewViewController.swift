//
//  BarrelOverviewViewController.swift
//  dpqrapp
//
//  Created by Vojtěch Honig on 06.12.16.
//  Copyright © 2016 Vojtěch Honig. All rights reserved.
//

import UIKit

class BarrelOverviewViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Properties
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var barrelImageView: UIImageView!
    @IBOutlet weak var barrelDescriptionTextView: UITextView!
    @IBOutlet weak var pubPickerView: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var beerPickerView: UIPickerView!
    @IBOutlet weak var completeStackView: UIStackView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    var indexOfBeer = 0
    var indexOfPub = 0
    var originalImage = 0
    var originalDescription = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pubPickerView.delegate = self
        pubPickerView.dataSource = self
        
        beerPickerView.delegate = self
        beerPickerView.dataSource = self
        
        navItem.title = barrelID
        
        let barrelImageRef = storage.child(barrelID)
        
        barrelImageRef.data(withMaxSize: 50 * 1024 * 1024) { (data, error) in
            
            if error == nil {
                
                let barrelImage = UIImage(data: data!)
                
                self.barrelImageView.image = barrelImage
                self.barrelImageView.alpha = 1
                
                self.activityIndicator.stopAnimating()
                self.barrelImageView.isUserInteractionEnabled = true
                
                self.originalImage = 1
                
            } else {
                
                self.activityIndicator.stopAnimating()
                self.barrelImageView.isUserInteractionEnabled = true
                
            }
            
        }
        
        realtimeDatabaseReference.child("/Sudy/\(barrelID)").observe(.value, with: { (snapshot) in
            
            if let dict = snapshot.value as? [String: String] {
                
                if let beerID = dict["Obsah"] {
                    
                    for (name, ID) in beerDict {
                        
                        if beerID == ID {
                            
                            if let index = beerArray.index(of: name) {
                                
                                self.indexOfBeer = index
                                self.beerPickerView.selectRow(index, inComponent: 0, animated: true)
                                
                            } else {
                                
                                print("ERROR: Chyba ve shodě piv")
                                
                            }
                            
                        }
                        
                    }
                    
                } else {
                    
                    print("ERROR: Chyba při načítání obsahu")
                    
                }
                
                if let pubID = dict["Místo"] {
                    
                    for (name, ID) in pubDict {
                        
                        if pubID == ID {
                            
                            if let index = pubArray.index(of: name) {
                                
                                self.indexOfPub = index
                                self.pubPickerView.selectRow(index, inComponent: 0, animated: true)
                                
                            } else {
                                
                                print("ERROR: Chyba ve shodě piv")
                                
                            }
                            
                        }
                        
                    }
                    
                } else {
                    
                    print("ERROR: Chyba při načítání místa")
                    
                }
                
                if let desc = dict["Popis"] {
                    
                    self.originalDescription = desc
                    
                    self.barrelDescriptionTextView.text = desc
                    
                }
                
            } else {
                
                print("ERROR: Chyba při načítání piva")
                
            }
            
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIPickerViewDataSource, UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView === pubPickerView {
        
            return pubArray[row]
        
        } else {
            
            return beerArray[row]
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        //Změna = pubArray[row]
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView === pubPickerView {
        
            return pubArray.count
            
        } else {
            
            return beerArray.count
            
        }
    }
    
    // MARK: - UITextView Delegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            
            textView.resignFirstResponder()
            return false
            
        }
        
        return true
        
    }
    
    // MARK: - Actions
    
    @IBAction func cancel(_ sender: Any) {
        
        self.performSegue(withIdentifier: "getBackSegue", sender: nil)
        
    }
    
    @IBAction func writeToDatabaseMenu(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Vyber", message: "Chceš uložit změny nebo smazat sud?", preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: "Uložit změny", style: .default) { (_) in
            
                self.saveChanges()
            
        }
        
        let deleteAction = UIAlertAction(title: "Smazat sud", style: .destructive) { (_) in
            
                self.deleteBarrel()
            
        }
        
        alert.addAction(saveAction)
        alert.addAction(deleteAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func changeBarrelPhoto(_ sender: UITapGestureRecognizer) {
        
        let actionSheet = UIAlertController(title: "Vyber způsob", message: "Chceš fotit nebo vybírat?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Zrušit", style: .cancel, handler: nil)
        
        let cameraAction = UIAlertAction(title: "Fotit", style: .default, handler: {
            (_) in
            
            self.present(self.createImagePickerController(source: .camera), animated: true, completion: nil)
            
        })
        let photoLibraryAction = UIAlertAction(title: "Vybrat", style: .default, handler: {
            (action) in
            
            self.present(self.createImagePickerController(source: .photoLibrary), animated: true, completion: nil)
            
        })
        
        actionSheet.addAction(cancelAction)
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photoLibraryAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - Handeling Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        barrelDescriptionTextView.resignFirstResponder()
        
    }
    
    // MARK: - Functions
    
    func createImagePickerController(source: UIImagePickerControllerSourceType) -> UIImagePickerController {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        
        imagePickerController.sourceType = source
        
        return imagePickerController
        
    }
    
    func deleteBarrel() {
        
        let alert = UIAlertController(title: "Smazat sud z databáze", message: "Určitě chceš smazat ten sud barane? Taková věc se nedá vrátit...", preferredStyle: .alert)
        
        let sureAction = UIAlertAction(title: "Jistě", style: .destructive) { (_) in
            
            realtimeDatabaseReference.child("Sudy/\(barrelID)").setValue(nil)
            
            storage.child(barrelID).delete(completion: { (error) in
                
                if let error = error {
                    
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    alert.addAction(cancelAction)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            })
            
            let index = barrelArray.index(of: barrelID)
            
            barrelArray.remove(at: index!)
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
        let noAction = UIAlertAction(title: "Ne/Nevim", style: .cancel, handler: nil)
        
        alert.addAction(sureAction)
        alert.addAction(noAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func saveChanges() {
        
        completeStackView.alpha = 0.3
        
        loadingActivityIndicator.startAnimating()
        
        if barrelImageView.alpha == 1 {
            
            if originalImage == 0 {
                
                let newPhoto = barrelImageView.image
                
                let imageData: Data = UIImagePNGRepresentation(newPhoto!)!
                
                task = storage.child(barrelID).put(imageData, metadata: nil)
                
            }
            
        }
        
        if pubPickerView.selectedRow(inComponent: 0) != indexOfPub {
            
            let index = pubPickerView.selectedRow(inComponent: 0)
            
            let name = pubArray[index]
            
            let ID = pubDict[name]
            
            realtimeDatabaseReference.child("/Sudy/\(barrelID)/Místo").setValue(ID)
            
        }
        
        if beerPickerView.selectedRow(inComponent: 0) != indexOfBeer
        {
            
            let index = beerPickerView.selectedRow(inComponent: 0)
            
            let name = beerArray[index]
            
            let ID = beerDict[name]
            
            realtimeDatabaseReference.child("/Sudy/\(barrelID)/Obsah").setValue(ID)
            
        }
        
        if barrelDescriptionTextView.text != originalDescription {
            
            if let desc = barrelDescriptionTextView.text {
                
                realtimeDatabaseReference.child("Sudy/\(barrelID)/Popis").setValue(desc)
                
            } else {
                
                let alert = UIAlertController(title: "Error", message: "Popisek nesmí být prázný ty barane!", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                
                alert.addAction(okAction)
                
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
        if task != nil {
            
            task!.observe(.success, handler: { (snapshot) in
                
                self.completeStackView.alpha = 1
                
                self.loadingActivityIndicator.stopAnimating()
                
                task = nil
                
                self.originalImage = 1
                
            })
            
            task!.observe(.failure, handler: { (snapshot) in
                
                self.completeStackView.alpha = 1
                
                self.loadingActivityIndicator.stopAnimating()
                
                let alert = UIAlertController(title: "Error", message: snapshot.error!.localizedDescription, preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alert.addAction(cancelAction)
                
                self.present(alert, animated: true, completion: nil)
                
            })
            
        } else {
            
            completeStackView.alpha = 1
            
            loadingActivityIndicator.stopAnimating()
            
        }
        
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let photo = info[UIImagePickerControllerOriginalImage] as! UIImage?
        
        barrelImageView.image = photo
        
        barrelImageView.alpha = 1
        
        originalImage = 0
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
