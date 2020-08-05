//struct DropDown {
//    var text = "Hello, World!"
//}

import UIKit
protocol MakeDropDownDataSourceProtocol{
    func registerTableViewCells() -> [RegisterTableViewCells]
    func createDataSource() -> [TableViewCellData]
    
    //Optional Methopd for item selection
    func actionHappenedAt(sender: Any?, cell: UITableViewCell)
    func updateViewBackground()
}

extension MakeDropDownDataSourceProtocol{
    func actionHappenedAt(sender: Any?, cell: UITableViewCell) {}
    func updateViewBackground() {}
}

@objcMembers
class DropDown: UIView {
    
    var tableViewHandler: TableViewHandler?
    var dropDownTableView: UITableView?
    var width: CGFloat = 0
    var offset:CGFloat = 0
    var makeDropDownDataSourceProtocol: MakeDropDownDataSourceProtocol?
    var viewPositionRef: CGRect?
    var isDropDownPresent: Bool = false
    
    func setUpDropDown(viewPositionReference: CGRect,  offset: CGFloat){
        configureTableViewHandler()
        self.addBorders()
        self.addShadowToView()
        self.frame = CGRect(x: viewPositionReference.minX, y: viewPositionReference.maxY + offset, width: 0, height: 0)
        dropDownTableView = UITableView(frame: CGRect(x: self.frame.minX, y: self.frame.minY, width: 0, height: 0))
        self.width = viewPositionReference.width
        self.offset = offset
        self.viewPositionRef = viewPositionReference
        dropDownTableView?.showsVerticalScrollIndicator = false
        dropDownTableView?.showsHorizontalScrollIndicator = false
//        dropDownTableView?.backgroundColor = UIColor.clear.alpha(0.4)
        dropDownTableView?.backgroundColor = UIColor.clear
        dropDownTableView?.separatorStyle = .none
        dropDownTableView?.allowsSelection = true
        dropDownTableView?.isUserInteractionEnabled = true
        dropDownTableView?.tableFooterView = UIView()
        self.addSubview(dropDownTableView!)
    }
    
    func configureTableViewHandler() {
        tableViewHandler = TableViewHandler(self, tableView: dropDownTableView ?? UITableView())
    }
    
    func showDropDown(height: CGFloat){
        if isDropDownPresent{
            self.hideDropDown()
            makeDropDownDataSourceProtocol?.updateViewBackground()
        }else{
            isDropDownPresent = true
            self.frame = CGRect(x: (self.viewPositionRef?.minX)!, y: (self.viewPositionRef?.maxY)! + self.offset, width: width, height: 0)
            self.dropDownTableView?.frame = CGRect(x: 0, y: 0, width: width, height: 0)
            self.dropDownTableView?.reloadData()
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.05, options: .curveLinear
                , animations: {
                self.frame.size = CGSize(width: self.width, height: height)
                self.dropDownTableView?.frame.size = CGSize(width: self.width, height: height)
            })
        }
    }
    
    func reloadDropDown(height: CGFloat){
        self.frame = CGRect(x: (self.viewPositionRef?.minX)!, y: (self.viewPositionRef?.maxY)!
            + self.offset, width: width, height: 0)
        self.dropDownTableView?.frame = CGRect(x: 0, y: 0, width: width, height: 0)
        self.dropDownTableView?.reloadData()
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.05, options: .curveLinear
            , animations: {
            self.frame.size = CGSize(width: self.width, height: height)
            self.dropDownTableView?.frame.size = CGSize(width: self.width, height: height)
        })
    }
    
    func setRowHeight(height: CGFloat){
        self.dropDownTableView?.rowHeight = height
        self.dropDownTableView?.estimatedRowHeight = height
    }
    
    func hideDropDown(){
        isDropDownPresent = false
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveLinear
            , animations: {
            self.frame.size = CGSize(width: self.width, height: 0)
            self.dropDownTableView?.frame.size = CGSize(width: self.width, height: 0)
        })
    }
    
    func removeDropDown(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveLinear
            , animations: {
            self.dropDownTableView?.frame.size = CGSize(width: 0, height: 0)
        }) { (_) in
            self.removeFromSuperview()
            self.dropDownTableView?.removeFromSuperview()
        }
    }
    
}

extension DropDown: TableViewHandlerProtocol {
    func handler(_ handler: TableViewHandler, registerTableViewCells tableView: UITableView) {
        if let tableViewCells = makeDropDownDataSourceProtocol?.registerTableViewCells() {
            for cell in tableViewCells {
                tableView.register(UINib(nibName: cell.nibName, bundle: nil), forCellReuseIdentifier: cell.reuseIdentifier)
            }
        }
    }
    
    func prepareDataSourceForHandler(_ handler: TableViewHandler) -> [TableViewCellData] {
        return makeDropDownDataSourceProtocol?.createDataSource() ?? [TableViewCellData]()
    }
    
    func handler(_ handler: TableViewHandler, didActionHappenedAt sender: Any?, cell: UITableViewCell) {
        makeDropDownDataSourceProtocol?.actionHappenedAt(sender: sender, cell: cell)
    }
    
}

//MARK: - UIView Extension
extension UIView{
    func addBorders(borderWidth: CGFloat = 0.2, borderColor: CGColor = UIColor.lightGray.cgColor){
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor
    }
    
    func addShadowToView(shadowRadius: CGFloat = 2, alphaComponent: CGFloat = 0.6) {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: alphaComponent).cgColor
        self.layer.shadowOffset = CGSize(width: -1, height: 2)
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = 1
    }
}


//MARK: - TableView Handler

protocol TableViewCellDataPopulation {
    func populate(_ data:Any)
}

protocol TableViewCellActionable: class {
    func didActionHappened(at sender:Any?, cell: UITableViewCell )
}

protocol TableViewCellActionableCallBack: class {
    var delegate: TableViewCellActionable? { get set }
}

protocol TableViewCellParentIdentification {
    func parentViewController(_ controller:Any)
}

class TableViewHandler:  NSObject, UITableViewDataSource, UITableViewDelegate, TableViewCellActionable {
    
    var data: [TableViewCellData]?

     var delegate: TableViewHandlerProtocol?
    
     func configureTableview(_ tableView: UITableView) {
        tableView.dataSource = self
        tableView.delegate = self
        
        //  If needed move the lines below out of the constructor
        prepare()
        self.delegate?.handler(self, registerTableViewCells: tableView)
        tableView.reloadData()
    }
    
     func configureDelegate(_ delegate: TableViewHandlerProtocol) {
        self.delegate = delegate
    }
    
    init(_ delegate: TableViewHandlerProtocol, tableView:UITableView) {
        super.init()
        configureDelegate(delegate)
        configureTableview(tableView)
    }
    
    func prepare() -> Void {
        prepareData()
    }
    
    func prepareData() -> Void {
        data = delegate?.prepareDataSourceForHandler(self)
    }

    func reloadData(dataModel:[TableViewCellData],tableView: UITableView) -> Void {
        
        DispatchQueue.main.async { [unowned self] in
            self.data = nil
            self.data = dataModel
            tableView.reloadData()
        }
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cellData = data?[indexPath.row],
            let cell = tableView.dequeueReusableCell(withIdentifier: cellData.identifier)
            
            else {
                return UITableViewCell()
            }
        
        if let dataPopulationCell = cell as? TableViewCellDataPopulation {
            dataPopulationCell.populate(cellData.data)
        }
        
        if let actionableCallBack = cell as? TableViewCellActionableCallBack {
            actionableCallBack.delegate = self
        }
        
        if let expertMatchCell = cell as? TableViewCellParentIdentification {
            expertMatchCell.parentViewController(self.delegate as Any)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegate?.customCell(willDisplayCell: cell)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.handler(self, didActionHappenedAt: tableView.cellForRow(at: indexPath), cell: tableView.cellForRow(at: indexPath) ?? UITableViewCell())
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func didActionHappened(at sender:Any?, cell: UITableViewCell ) {
        self.delegate?.handler(self, didActionHappenedAt: sender, cell: cell)
    }
}


protocol TableViewHandlerProtocol {
    func handler(_ handler:TableViewHandler, registerTableViewCells tableView:UITableView)
    func prepareDataSourceForHandler(_ handler: TableViewHandler) -> [TableViewCellData]
    func handler(_ handler:TableViewHandler, didActionHappenedAt sender:Any?, cell: UITableViewCell)
    func customCell(willDisplayCell cell : UITableViewCell)
}

extension TableViewHandlerProtocol {
    func handler(_ handler:TableViewHandler, didActionHappenedAt sender:Any?, cell: UITableViewCell) {}
    func customCell(willDisplayCell cell : UITableViewCell) {}
}

protocol CustomCellDelegateCallBack : class {
    var cellDelegate : CustomCellDelegate? { get set }
}

protocol CustomCellDelegate : class {
    func customCell(cellDidAppear cell : UITableViewCell)
}

extension CustomCellDelegate {
    func customCell(cellDidAppear cell : UITableViewCell) {}
}

class TableViewCellData: NSObject {
    var identifier: String = ""
    var data: Any
    
    init(_ identifier:String, data:Any) {
        self.identifier = identifier
        self.data = data
    }
}

class RegisterTableViewCells: NSObject {
    var nibName: String = "nibName"
    var reuseIdentifier: String = "reuseIdentifier"
    
    init(nibName: String, reuseIdentifier: String) {
        self.nibName = nibName
        self.reuseIdentifier = reuseIdentifier
    }
}


extension UIResponder {
    func next<U: UIResponder>(of type: U.Type = U.self) -> U? {
        return self.next.flatMap({ $0 as? U ?? $0.next() })
    }
}

extension UITableViewCell {
    var tableView: UITableView? {
        return self.next(of: UITableView.self)
    }

    var indexPath: IndexPath? {
        return self.tableView?.indexPath(for: self)
    }
}
