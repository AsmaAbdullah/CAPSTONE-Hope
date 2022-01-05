//
//  SessionContent.swift
//  HOPE
//
//  Created by Asma on 09/12/2021.
//

import UIKit
import CoreData
import FirebaseAuth
import FirebaseFirestore

class SessionContent: UIViewController {
    
    
    var selectedSession: Session!
    var arraySession = [Session]()
    var mySession = [String]()

    
    @IBOutlet weak var imageSession: UIImageView!
    @IBOutlet weak var titleSession: UILabel!
    @IBOutlet weak var sessionContent: UILabel!
    @IBOutlet weak var enrollButton: UIButton!
    
    
    // MARK: - SAVE CORE DATA
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BeneficiarySessions")
        container.loadPersistentStores (completionHandler: { desc, error in
            if let readError = error {
                print(readError)
            }
        })
        return container
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageSession.image = UIImage(named: selectedSession.image)
        titleSession.text = selectedSession.titleSessions
        sessionContent.text = selectedSession.Content
        
        
        imageSession.layer.cornerRadius = 12
        imageSession.layer.borderColor = UIColor.lightGray.cgColor
        imageSession.layer.borderWidth = 1.0
    }
    
    @IBAction func enrollSession(_ sender: UIButton) {
        
        let sessionsLists = fetchAllLists()
        
        for sessionList in sessionsLists {
            if sessionList.titleSession == selectedSession.titleSessions {
                
                let alertController = UIAlertController(title: "", message: "You Already have added this session", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
        }
        
        createNewList(titleSession: selectedSession.titleSessions  , imageSession:  selectedSession.image)
        
        let alertController = UIAlertController(title: "", message: "Has been successfully added", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        

        
    }
    
    // MARK: - CORE-DATA
    
    func createNewList(titleSession: String, imageSession: String){
        
        let context = persistentContainer.viewContext
        context.performAndWait {
            let list = YourSessionsList(context: context)
            list.titleSession = titleSession
            list.imageSession = imageSession
            list.uid = Auth.auth().currentUser?.uid ?? ""
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }
    
    
    func fetchAllLists() -> [YourSessionsList]{
        let context = persistentContainer.viewContext
        var yourSessionsList : [YourSessionsList] = []
        
        do {
           yourSessionsList = try context.fetch(YourSessionsList.fetchRequest())
        } catch {
            print(error)
        }
        
        return yourSessionsList
    }
    
    
    
}
