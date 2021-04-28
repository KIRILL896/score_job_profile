

import UIKit
import RxSwift
import RxCocoa


extension ProfileModule.RateHistory.ViewController {
  class DetailCell: UITableViewCell, Reusable {
    // MARK: - subviews
    
    let table: UITableView = {
      let view = UITableView()
      view.round()
      view.backgroundColor = .white
      view.tableFooterView = UIView()
      view.separatorInset = .zero//UIEdgeInsets(top: 0, left: 16 + 44 + 16, bottom: 0,   right: 0)
      view.register(RightDetailCell.self, forCellReuseIdentifier: RightDetailCell.reuseIdentifier)
      return view
    }()
    
    
    let button:UIButton = {
        let b = UIButton(type: .custom)
        b.backgroundColor = .gray
        b.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        b.layer.cornerRadius = 5.0
        b.setTitle("click", for: .normal)
        return b
    }()
    
    var tableConstraint: NSLayoutConstraint!
    
    var const: NSLayoutConstraint!
    
    var sizer = PublishSubject<Void>()
    
    
    var scoredMeTableLeading: NSLayoutConstraint!

    // MARK: - data && rx
    let disposeBag = DisposeBag()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      setupConstraint()
    }
    
    required init?(coder: NSCoder) {
      super.init(coder: coder)
      setupConstraint()
    }
    
    // MARK: - constraints
    func setupConstraint() {
        self.backgroundColor = .white
        
        let scrollview = UIScrollView()
        scrollview.autoresizingMask = .flexibleHeight
        scrollview.backgroundColor = Colors.screenBg

        self.addSubview(scrollview)
        scrollview.makeAnchors { make in
          make.top(equalTo: self.top)
          make.bottom(equalTo: self.safeBottom)
          make.leading(equalTo: self.leading)
          make.trailing(equalTo: self.trailing)
        }
        
        
        let tableOffset: CGFloat = -16 - 44 - 16 // offset for button done
        
        
        scrollview.addSubview(table)
        table.makeAnchors { make in
          make.top(equalTo: scrollview.top, constant: 16)
          make.width(equalTo: scrollview.width, constant: -32)
          make.bottom(equalTo: scrollview.bottom, constant: tableOffset)
          make.leading(equalTo: scrollview.leading, constant: 16)
          make.trailing(equalTo: scrollview.trailing, constant: -16)
        }

        
        tableConstraint = table.height(0)
        tableConstraint.isActive = true
        
        const =  self.height(0)
        const.isActive = true
    
    }
  }
}

extension ProfileModule.RateHistory.ViewController.DetailCell {
  func setup(model: RateHistoryCellModel) {
            
          let scoreElems = Observable<[Score.ScoreElem]>.just(model.elems)
            
           self.table.delegate = nil
           self.table.dataSource = nil
           table.delegate = nil
    
          scoreElems.bind(
          to: table.rx.items(
            cellIdentifier: RightDetailCell.reuseIdentifier,
            cellType: RightDetailCell.self)
        ) { row, model, cell in
          let evaluate = model.evaluated ?? 0.0
          cell.title.text = model.question.name
          cell.subtitle.text = evaluate.string(fractionDigits: 1)
        }
        .disposed(by: disposeBag)
        
        scoreElems
          .debounce(.milliseconds(1), scheduler: MainScheduler.instance)
          .bind { [unowned self] _ in
            self.tableConstraint.constant = self.table.contentSize.height
            self.const.constant = self.table.contentSize.height
          }
          .disposed(by: disposeBag)
        
        sizer.bind { [unowned self] _ in
          self.tableConstraint.constant = self.table.contentSize.height
            self.const.constant = self.table.contentSize.height
              UIView.animate(withDuration: 0.25) {
                self.table.layoutIfNeeded()
              }
        }
        .disposed(by: disposeBag)
        

        scoreElems
          .asObservable()
          .delay(.milliseconds(1), scheduler: MainScheduler.instance)
          .bind { [unowned self] data in

            self.sizer.onNext(())
          }
          .disposed(by: disposeBag)
        
        
         scoreElems
          .asObservable()
          .mapToVoid()
          .delay(.seconds(1), scheduler: MainScheduler.instance)
          .bind { [unowned self] _ in
            self.sizer.onNext(())
          }
          .disposed(by: disposeBag)
    
    
    
  }
}
