//
//  ListController.swift
//  Protein
//
//  Created by Etienne Tranchier on 05/01/2019.
//  Copyright © 2019 Etienne Tranchier. All rights reserved.
//

import UIKit
import SceneKit

class ListController: UIViewController {
    
    let tableView : UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.showsHorizontalScrollIndicator = false
        tv.showsVerticalScrollIndicator = false
        return tv
    }()
    
    let searchBar : UISearchBar = {
        let sb = UISearchBar()
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    var ligands : [String]? {
        didSet {
            if ligands != nil {
                dataSource = ligands!
            }
        }
    }
    var dataSource : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .white
        
        searchBar.delegate = self
        tableView.register(LigandCell.self, forCellReuseIdentifier: "cell")
        searchBar.showsBookmarkButton = true
        searchBar.setImage(UIImage(named: "exit"), for: .bookmark, state: .normal)

        for subview in searchBar.subviews.last!.subviews {
            print(subview)
            if subview.isKind(of: NSClassFromString("UISearchBarBackground")!) {
                
                for v in subview.subviews {
                    if v.isKind(of: NSClassFromString("_UISearchBarSearchFieldBackgroundView")!) {
                        v.removeFromSuperview()
                    }
                }
                subview.removeFromSuperview()
            }
        }
        searchBar.barTintColor = .clear
        searchBar.backgroundColor = .clear
        searchBar.isTranslucent = true
        
        // Do any additional setup after loading the view.
        setupView()
    }
    
    func setupView() {
        let background = UIImage(named: "backgroung42")
        view.backgroundColor = UIColor(patternImage: background!)
        tableView.backgroundColor = .clear
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            searchBar.widthAnchor.constraint(equalTo: view.widthAnchor),
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            searchBar.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier : 0.8),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func parse(_ s : [String]) -> Ligand {
        var ret = Ligand.init(name: "", shapes: [], tubes: [])
        for line in s {
            var d = line.components(separatedBy: .whitespaces)
            if d[0] == "ATOM" {
                d = d.filter({ (s) -> Bool in
                    return s != "" ? true : false
                })
                print(d)
                let sha = Shape.init(id: Int(d[1])!, name: d[2] ,type: d.last!, pos: SCNVector3(x: Float(d[6])! * 2, y: Float(d[7])! * 2, z: Float(d[8])! * 2), color: nil)
                ret.shapes.append(sha)
            } else if d[0] == "CONECT" {
                d = d.filter({ (s) -> Bool in
                    return s != "" ? true : false
                })
                for i in 2...(d.count - 1) {
                    let tu = Tube.init(from: Int(d[1])!, to: Int(d[i])!, times: 1)
                    ret.tubes.append(tu)
                }
            }
        }
        return ret
    }

}

extension ListController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! LigandCell
        cell.ligand = dataSource[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scene = SceneController()
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let url = URL(string: "http://files.rcsb.org/ligands/view/\(dataSource[indexPath.row] )_ideal.pdb")
        do {
            let data = try String(contentsOf: url!, encoding: String.Encoding.utf8)

            let ret = data.components(separatedBy: NSCharacterSet.newlines)
            var ligand : Ligand = parse(ret)
            
            ligand.name = dataSource[indexPath.row]
            scene.ligand = ligand
            // a retirer pour voir l'indicateur (trop rapide)
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            self.present(scene, animated: true, completion: nil)
            
        } catch(let err) {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            print(err.localizedDescription)
        }
        
    }
}

extension ListController : UISearchBarDelegate {
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataSource = ligands!.filter { (string) -> Bool in
            if string.lowercased().range(of:searchText) != nil {
                return true
            }
            return false
        }
        if searchText == "" {
            dataSource = ligands!
        }
        tableView.reloadData()
    }
}
