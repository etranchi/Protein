//
//  ViewController.swift
//  Protein
//
//  Created by Etienne Tranchier on 05/01/2019.
//  Copyright © 2019 Etienne Tranchier. All rights reserved.
//


import UIKit
import LocalAuthentication

public func makeAlert(_ msg : String) {
    // to check
    if let cont = UIApplication.shared.keyWindow?.rootViewController {
        let al = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        al.addAction(UIAlertAction(title: "Ok", style: .default, handler: { me in
            al.dismiss(animated: true, completion: nil)
        }))
        cont.present(al, animated: true, completion: nil)
    }
    
}

class LoginController: UIViewController , URLSessionDelegate {
    let jsonEncoder = JSONEncoder()
    let authenticationContext = LAContext()
    let button : UIButton = {
        let b = UIButton(type: .roundedRect)
        b.layer.cornerRadius = 25
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = UIColor(red: 0, green: 186, blue: 188, alpha: 1)
        b.setAttributedTitle(NSAttributedString(string: "Go", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white]), for: .normal)
        return b
    }()
    
    let login : UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor.gray
        tf.layer.cornerRadius = 25
        tf.textAlignment = .center
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.layer.borderColor = UIColor(red: 0, green: 186, blue: 188, alpha: 1).cgColor
        tf.attributedPlaceholder = NSAttributedString(string: "Login", attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        tf.textColor = UIColor.white
        return tf
    }()
    
    let pass : UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor.gray
        tf.layer.cornerRadius = 25
        tf.textAlignment = .center
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.layer.borderColor = UIColor(red: 0, green: 186, blue: 188, alpha: 1).cgColor
        tf.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        tf.textColor = UIColor.white
        return tf
    }()
    
    let touch : UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.addTarget(self, action: #selector(goToProfileTouch), for: .touchUpInside)
        bt.setImage(UIImage(named: "touch-id")?.withRenderingMode(.alwaysOriginal), for: .normal)
        bt.imageView?.contentMode = .scaleAspectFit
        return bt
    }()
    
    @objc func goToProfile() {
        do {
            if let path = Bundle.main.path(forResource: "ligands", ofType: "txt"){
                let data = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
                
                let ligands = data.components(separatedBy: NSCharacterSet.newlines)
                let list = ListController()
                list.ligands = ligands
                self.present(list, animated: true, completion: nil)
            }
        } catch let err as NSError {
            //do sth with Error
            print(err)
        }
    }
    
    @objc func goToProfileTouch() {
        authenticationContext.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Only awesome people are allowed",
            reply: { [unowned self] (success, error) -> Void in
                
                if( success ) {
                    
                    // Fingerprint recognized
                    // Go to view controller
                    do {
                        if let path = Bundle.main.path(forResource: "ligands", ofType: "txt"){
                            let data = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
                            
                            let ligands = data.components(separatedBy: NSCharacterSet.newlines)
                            let list = ListController()
                            list.ligands = ligands
                            self.present(list, animated: true, completion: nil)
                        }
                    } catch let err as NSError {
                        //do sth with Error
                        print(err)
                    }
                }else {
                    // Check if there is an error
                    makeAlert("Error with the TouchID")
                }
                
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        touch.isHidden = false
        super.viewWillAppear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            touch.isHidden = true
            return
        }
        
        
    }
    
    func setupView() {
        login.delegate = self
        view.addSubview(login)
        view.addSubview(pass)
        view.addSubview(button)
        view.addSubview(touch)
        button.addTarget(self, action: #selector(goToProfile), for: .touchUpInside)
        
        let middle = view.bounds.height / 2.5
        let padding : CGFloat = 20
        
        NSLayoutConstraint.activate([
            login.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            login.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            login.heightAnchor.constraint(equalToConstant: 50),
            login.topAnchor.constraint(equalTo: view.topAnchor, constant: (middle - padding)),
            
            pass.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pass.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            pass.heightAnchor.constraint(equalToConstant: 50),
            pass.topAnchor.constraint(equalTo: login.bottomAnchor, constant: padding),
            
            button.topAnchor.constraint(equalTo: pass.bottomAnchor, constant: padding),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalTo: login.widthAnchor, multiplier: 0.5),
            button.heightAnchor.constraint(equalToConstant: 50),
            
            touch.topAnchor.constraint(equalTo: button.bottomAnchor, constant: padding),
            touch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            touch.widthAnchor.constraint(equalTo: login.widthAnchor, multiplier: 0.5),
            touch.heightAnchor.constraint(equalToConstant: 50)
            ])
    }
    
    //    func getUser(_ search : String, completion: @escaping ((User?) -> ())) {
    //        print(search)
    //        let w = search.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    //        let url = URL(string: "https://api.intra.42.fr/v2/users/\(w)")
    //        var req = URLRequest(url: url!)
    //        req.httpMethod = "GET"
    //        req.setValue("Bearer \(CREDENTIALS!.access_token)", forHTTPHeaderField: "Authorization")
    //        doIt(req: req, type: User.self) { (ret) in
    //            completion(ret)
    //        }
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let background = UIImage(named: "backgroung42")
        view.backgroundColor = UIColor(patternImage: background!)
        setupView()
        // Do any additional setup after loading the view.
    }
    
    
    //    func doIt<T : Decodable>(req: URLRequest, type : T.Type, completion: @escaping((T?) -> ())) {
    //        URLSession(configuration: .default, delegate: self, delegateQueue: .main).dataTask(with: req) { (data, response, err) in
    //            if err != nil {
    //                makeAlert("No response from the server, try again..")
    //                completion(nil)
    //            }
    //            if let d = data {
    //                do {
    //                    let ret = try JSONDecoder().decode(T.self, from: d)
    //                    completion(ret)
    //                }
    //                catch (let err){
    //                    makeAlert(err.localizedDescription)
    //                    completion(nil)
    //                }
    //            }
    //            }.resume()
    //    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension LoginController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        goToProfile()
        return true
    }
}
