//
//  SceneController.swift
//  Protein
//
//  Created by Etienne Tranchier on 05/01/2019.
//  Copyright © 2019 Etienne Tranchier. All rights reserved.
//

import UIKit
import SceneKit

class SceneController: UIViewController {
    var ligand : Ligand? {
        didSet {
            if ligand != nil {
                
            }
        }
    }
    var colorShapes : [(Int, UIColor)] = []
    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var isRotating = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupCamera()
        lightSetup()
        setupShapes(ligand!.shapes)
        setupTubes(ligand!.tubes)
    }
    
    func shouldAutorotate() -> Bool {
        return true
    }
    
    func lightSetup() {
        let ambientLightNode = SCNNode()
        ambientLightNode.name = "light"
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLight.LightType.ambient
        ambientLightNode.light!.color = UIColor(white: 0.67, alpha: 1.0)
        scnScene.rootNode.addChildNode(ambientLightNode)
        
        let omniLightNode = SCNNode()
        omniLightNode.name = "light"
        omniLightNode.light = SCNLight()
        omniLightNode.light!.type = SCNLight.LightType.omni
        omniLightNode.light!.color = UIColor(white: 0.75, alpha: 1.0)
        omniLightNode.position = SCNVector3Make(0, 50, 50)
        scnScene.rootNode.addChildNode(omniLightNode)
        
    }
    func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    let dissmis : UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.setImage(UIImage(named: "exit"), for: .normal)
        bt.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return bt
    }()
    
    let name : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .right
        return lb
    }()
    
    let selectedLb : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .right
        return lb
    }()
    
    let play : UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        bt.setImage(UIImage(named: "play"), for: .normal)
        return bt
    }()
    
    let shareB : UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.addTarget(self, action: #selector(shareScn), for: .touchUpInside)
        bt.setImage(UIImage(named: "share"), for: .normal)
        return bt
    }()
    
    @objc func shareScn() {
        let img = scnView.snapshot()
        img.share()
    }
    
    func makeRotate() {
        DispatchQueue.main.async {
            let loopAction = SCNAction.repeatForever(SCNAction.rotate(by: 2, around: SCNVector3(x: 1, y: 1, z: 1), duration: 5.0))
            self.scnScene.rootNode.runAction(loopAction, forKey : "rotation")
            self.play.setImage(UIImage(named: "pause"), for: .normal)
            
        }
        
    }
    
    @objc func handlePlay() {
        if isRotating {
            DispatchQueue.main.async {
                self.scnScene.rootNode.removeAction(forKey: "rotation")
                self.play.setImage(UIImage(named: "play"), for: .normal)
                
            }
        } else {
            makeRotate()
        }
        isRotating = !isRotating
    }
    
    @objc func tapGesture(_ sender : UITapGestureRecognizer) {
        let location: CGPoint = sender.location(in: self.view)
        let hits = self.scnView.hitTest(location, options: nil)
        if let tappedNode = hits.first?.node{
            if ((tappedNode.geometry as? SCNSphere) != nil) {
                selectedLb.text = tappedNode.name!
            }
        }
    }
    
    func setupView() {
        
        scnView = SCNView()
        scnView.showsStatistics = true
        scnView.allowsCameraControl = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        scnView.addGestureRecognizer(gesture)
        self.view = scnView
        name.text = ligand!.name
        scnView.addSubview(dissmis)
        scnView.addSubview(name)
        scnView.addSubview(selectedLb)
        scnView.addSubview(play)
        scnView.addSubview(shareB)
        NSLayoutConstraint.activate([
            dissmis.widthAnchor.constraint(equalToConstant: 50),
            dissmis.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            dissmis.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            dissmis.heightAnchor.constraint(equalToConstant: 50),
            
            name.rightAnchor.constraint(equalTo: view.rightAnchor, constant : -20),
            name.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            name.heightAnchor.constraint(equalToConstant: 50),
            name.widthAnchor.constraint(equalTo: view.widthAnchor, constant : -50),
            
            selectedLb.rightAnchor.constraint(equalTo: view.rightAnchor, constant : -20),
            selectedLb.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 0),
            selectedLb.heightAnchor.constraint(equalToConstant: 50),
            selectedLb.widthAnchor.constraint(equalTo: view.widthAnchor, constant : -50),
            
            play.leftAnchor.constraint(equalTo: view.leftAnchor, constant : 30),
            play.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            play.heightAnchor.constraint(equalToConstant: 50),
            play.widthAnchor.constraint(equalToConstant: 50),
            
            shareB.rightAnchor.constraint(equalTo: view.rightAnchor, constant : -30),
            shareB.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            shareB.heightAnchor.constraint(equalToConstant: 50),
            shareB.widthAnchor.constraint(equalToConstant: 50),
            
            ])
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnScene.fogColor = UIColor.clear
        scnView.scene = scnScene
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 150)
        cameraNode.camera?.zFar = 500
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    func setupShapes(_ sh : [Shape]) {
        for d in sh {
            let sphere = SCNSphere(radius: 0.5)
            var color : UIColor
            switch d.type {
            case "H" : color = .white
            case "C" : color = .black
            case "N": color = .blue
            case "O" : color = .red
            case "F","Cl" : color = .green
            case "P" : color = UIColor.orange
            case "S" : color = .yellow
            case "Li","Na","K","Rb","Cs","Fr" : color = .purple
            case "Ti" : color = .gray
            default : color = .black
            }
            sphere.firstMaterial?.diffuse.contents = color
            let node = SCNNode(geometry: sphere)
            node.position = d.pos
            node.name = d.name
            colorShapes.append((d.id, color))
            scnScene.rootNode.addChildNode(node)
        }
    }
    
    
    func setupTubes(_ tu : [Tube]) {
        tu.forEach { (d) in
            let from = ligand!.shapes.first(where: { (sh) -> Bool in
                return sh.id == d.from ? true : false
            })
            let to = ligand!.shapes.first(where: { (sh) -> Bool in
                return sh.id == d.to ? true : false
            })
            let s1 = colorShapes.first(where: { (id,color) -> Bool in
                return id == from!.id ? true : false
            })
            let s2 = colorShapes.first(where: { (id,color) -> Bool in
                return id == to!.id ? true : false
            })
            let cylinder = Cylinder(parent: scnScene.rootNode, s1: from!, s2: to!, radius: 0.2, radSegmentCount: 6, s1Color : s1!.1, s2Color : s2!.1)
            
            scnScene.rootNode.addChildNode(cylinder)
        }
    }
}


extension SCNVector3 {
    func distance(_ receiver:SCNVector3) -> Float{
        let xd = receiver.x - self.x
        let yd = receiver.y - self.y
        let zd = receiver.z - self.z
        let distance = Float(sqrt(xd * xd + yd * yd + zd * zd))
        return (distance)
    }
}


class Cylinder: SCNNode
{
    init( parent: SCNNode,
          s1: Shape,
          s2: Shape,
          radius: CGFloat,
          radSegmentCount: Int,
          s1Color : UIColor,
          s2Color : UIColor
        )
    {
        super.init()
        let v1 = s1.pos
        let v2 = s2.pos
        let height = v1.distance(v2)
        
        position = v1
        let dif = v1.z - v2.z
        print(dif)
        print(v1)
        print(v2)
        
        let node = SCNNode()
        node.position = v2
        parent.addChildNode(node)
        
        let ZAlign = SCNNode()
        ZAlign.eulerAngles.x = .pi / 2
        
        let geo = SCNCylinder(radius: radius, height: CGFloat(height / 2))
        geo.radialSegmentCount = radSegmentCount
        geo.firstMaterial!.diffuse.contents = s1Color
        let nodeCyl = SCNNode(geometry: geo)
        nodeCyl.position.y = -height / 4
        
        ZAlign.addChildNode(nodeCyl)
        
        addChildNode(ZAlign)
        
        constraints = [SCNLookAtConstraint(target: node)]
    }
    
    override init() {
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
