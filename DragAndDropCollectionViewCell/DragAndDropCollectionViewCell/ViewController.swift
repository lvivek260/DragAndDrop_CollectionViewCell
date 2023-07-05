//
//  ViewController.swift
//  DragAndDropCollectionViewCell
//
//  Created by PHN MAC 1 on 31/05/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var myCollectionView: UICollectionView!
    var question: [[String]] = [
        ["10","=","6","+","4"],
        ["-","5","6","1","="],
        ["3","9","=","27","*"]
    ]
    let answer: [[String]] = [
        ["6","+","4","=","10"],["4","+","6","=","10"],
        ["6","-","1","=","5"],["6","-","5","=","1"],
        ["3","*","9","=","27"],["9","*","3","=","27"]
    ]
    var question_: [[String]] = []
    var index: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        question_ = question
    }
    
    @IBAction func submitBtnClick(_ sender: Any) {
        if (question[index] == answer[index*2]) || question[index] == answer[index*2+1]{
            alertMessage(condition: true, title: "Congrats!", message: "You entered the correct answer")
        }
        else {
            alertMessage(condition: false, title: "Wrong!", message: "You entered the wrong answer")
        }
    }
    func alertMessage(condition:Bool, title:String?, message:String?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var alertAction = UIAlertAction()
        if condition{
            alertAction = UIAlertAction(title: "Next", style: .default){_ in
                self.index += 1
                self.myCollectionView.reloadData()
            }
        }
        else{
            alertAction = UIAlertAction(title: "Re-Try", style: .default){_ in
                self.question = self.question_
                self.myCollectionView.reloadData()
            }
        }
        
        alert.addAction(alertAction)
        self.present(alert, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate{
    // DataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return question[index].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = myCollectionView.dequeueReusableCell(withReuseIdentifier: "myCollectionViewCell", for: indexPath) as? myCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.ansLbl.text = question[index][indexPath.row]
        return cell
    }
    
    //DelegateFlowLayout Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
    }
    
    //Delegate Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 80
        let width: CGFloat = myCollectionView.frame.width - 40
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
     
}

extension ViewController: UICollectionViewDragDelegate{
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = indexPath.row
        let itemProvider = NSItemProvider(object: "\(item)" as NSString)
        let drageItem = UIDragItem(itemProvider: itemProvider)
        drageItem.localObject = item
        return [drageItem]
    }
}
extension ViewController: UICollectionViewDropDelegate{
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let myProposal = UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        return myProposal
    }
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        if let destinationIndexPath = coordinator.destinationIndexPath{
            let items = coordinator.items
            if items.count == 1{
                let item = items.first
                let sourceIndexPath = item?.sourceIndexPath
                collectionView.performBatchUpdates({
                    collectionView.deleteItems(at: [sourceIndexPath!])
                    collectionView.insertItems(at: [destinationIndexPath])
                    // if we have any array update that array here
                    let drageIndex = sourceIndexPath!.row as Int
                    let dropeIndex = destinationIndexPath.row
                    let arr = question
                    
                    let temp = question[index][drageIndex]
                    if drageIndex < dropeIndex{
                        for i in drageIndex ... dropeIndex - 1{
                            question[index][i] = question[index][i+1]
                        }
                    }
                    else if drageIndex > dropeIndex{
                        for i in dropeIndex + 1 ... drageIndex{
                            question[index][i] = arr[index][i-1]
                        }
                    }
                    else{}
                    question[index][dropeIndex] = temp
                })
                coordinator.drop(items.first!.dragItem, toItemAt: destinationIndexPath)
            }
        }
    }
}
