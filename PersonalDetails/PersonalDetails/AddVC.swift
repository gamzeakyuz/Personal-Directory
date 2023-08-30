//
//  AddVC.swift
//  PersonalDetails
//
//  Created by Gamze Akyüz on 27.08.2023.
//

import UIKit
import CoreData

class AddVC: UIViewController , UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var surnameTextfield: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var phonenumberTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    
    var personEntity = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.black
        
        
//        imgView
        imgView.layer.borderColor = UIColor.black.cgColor
        imgView.layer.borderWidth = 1.032
        
//        txtView
        txtView.layer.borderColor = UIColor.gray.cgColor
        txtView.layer.borderWidth = 1.0
        
//        imgPicker
        imgView.isUserInteractionEnabled = true
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imgView.addGestureRecognizer(imgTap)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imgView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        if nameTextfield.text != "" && surnameTextfield.text != "" && locationTextfield.text != "" && phonenumberTextfield.text != "" && emailTextfield.text != "" {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let newPerson = NSEntityDescription.insertNewObject(forEntityName: "Person", into: context)
            
            newPerson.setValue(UUID(), forKey: "id")
            newPerson.setValue(nameTextfield.text!, forKey: "name")
            newPerson.setValue(surnameTextfield.text!, forKey: "surname")
            newPerson.setValue(locationTextfield.text!, forKey: "location")
            newPerson.setValue(datePicker.date, forKey: "dateofbirthday")
            newPerson.setValue(phonenumberTextfield.text!, forKey: "pnumber")
            newPerson.setValue(emailTextfield.text!, forKey: "eposta")
            newPerson.setValue(txtView.text!, forKey: "mdetails")
            
            let data = imgView.image?.jpegData(compressionQuality: 0.5)
            newPerson.setValue(data, forKey: "img")
            
            do {
                try context.save()
                dismiss(animated: true, completion: nil)
                print("New Person Added")
            }catch {
                print("Error Saving Context : \(error.localizedDescription)")
            }

            NotificationCenter.default.post(name: NSNotification.Name("newPerson"), object: nil)
            self.navigationController?.popViewController(animated: true)
        }else {
            let alert = UIAlertController(title: "Alert!", message: "there are empty fields", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        
    }
}
