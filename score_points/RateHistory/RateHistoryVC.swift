

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

extension ProfileModule.RateHistory {
  class ViewController: BaseViewController {
    // MARK: subviews
    let scoredByMeTable: UITableView = {
      let view = UITableView()
      view.backgroundColor = .white
      view.tableFooterView = UIView()
      view.rowHeight = UITableView.automaticDimension
      view.separatorInset = UIEdgeInsets(top: 0, left: 16 + 44 + 16, bottom: 0,   right: 0)
      view.register(Cell.self, forCellReuseIdentifier: Cell.reuseIdentifier)
      view.register(DetailCell.self, forCellReuseIdentifier: DetailCell.reuseIdentifier)
      return view
    }()
    
    let scoredMeTable: UITableView = {
      let view = UITableView()
      view.tableFooterView = UIView()
      view.backgroundColor = .white
      
      view.separatorInset = UIEdgeInsets(top: 0, left: 16 + 44 + 16, bottom: 0,   right: 0)
      view.register(Cell.self, forCellReuseIdentifier: Cell.reuseIdentifier)
      view.register(DetailCell.self, forCellReuseIdentifier: DetailCell.reuseIdentifier)
      return view
    }()
    
    let scoredMeEmpty: UILabel = {
      let view = UILabel()
      view.alpha = 0
      view.textColor = Colors.subtitleText
      view.text = "Nobody has rated you yet"
      return view
    }()
    
    let scoredByMeEmpty: UILabel = {
      let view = UILabel()
      view.alpha = 0
      view.textColor = Colors.subtitleText
      view.text = "You haven't rated anyone yet"
      return view
    }()
    

    
    let segment: UISegmentedControl = {
      let view = UISegmentedControl()
      view.backgroundColor = .white
      view.insertSegment(withTitle: "Received Score", at: 0, animated: false)
      view.insertSegment(withTitle: "Given Score", at: 1, animated: false)
      view.selectedSegmentIndex = 0
      return view
    }()
    
    var scoredMeTableLeading: NSLayoutConstraint!

    // MARK: - data && rx
    let disposeBag = DisposeBag()
    var viewModel: ViewModel!
    let ratingType = BehaviorSubject<ScoreType>(value: .social)
    
    let deletedScore = PublishSubject<RateHistoryCellModel>()
    
    // MARK: - lifecycle
    override func viewDidLoad() {
      super.viewDidLoad()
      self.navigationItem.title = "Scoring History"
      addNotificationButton()
      setupConstraints()
      setupViewModelInput()
      setupViewModelOutput()
    }

    
  }
}

// MARK: - Data
extension ProfileModule.RateHistory.ViewController {
  func setupViewModelInput() {
    let bindings = ProfileModule.RateHistory.ViewModel.Bindings(
      myRateDeleted: deletedScore.asDriverOnErrorJustComplete(),
      myRateSelected: scoredMeTable.rx 
        .modelSelected(RateHistoryCellModel.self)
        .asDriver(),
      otherRateSelected: scoredByMeTable.rx
        .modelSelected(RateHistoryCellModel.self)
        .asDriver())
    viewModel.configure(with: bindings)
  }
  
  func setupViewModelOutput() {
    segment.rx
      .selectedSegmentIndex
      .map { index -> Bool in // is score by me
        if index == 1 { return false }
        return true
      }
    .observeOn(MainScheduler.instance)
    .bind(onNext: { [unowned self] scoreType in
      if scoreType {
        self.scoredMeTableLeading.constant = 0
        UIView.animate(withDuration: 0.25, animations: {
          self.view.layoutIfNeeded()
        }) { [weak self] _ in
          self?.scoredMeTable.alpha = 0
        }
      } else {
        self.scoredMeTable.alpha = 1
        self.scoredMeTableLeading.constant = UIScreen.main.bounds.width
        UIView.animate(withDuration: 0.25) {
          self.view.layoutIfNeeded()
        }
      }
      
    }).disposed(by: disposeBag)
    
    

    
    
    
    viewModel.scoredByMe.bind(
      to: scoredByMeTable.rx.items(
        cellIdentifier: Cell.reuseIdentifier,
        cellType: Cell.self)
    ) { row, model, cell in
      cell.setup(model: model)
    }
    .disposed(by: disposeBag)
    
    let dataSource = RxTableViewSectionedReloadDataSource<RateHistorySectionModel>(configureCell: { _, table, indexPath, item in
        if item.elems.count == 0 {
            let cell = table.dequequeCell(Cell.self, for: indexPath)
            cell.setup(model: item)
            return cell
        } else {
            let cell = table.dequequeCell(DetailCell.self, for: indexPath)
            cell.setup(model: item)
            return cell
        }
    }, canEditRowAtIndexPath: {_,_ in
        return true
    })
    scoredMeTable.delegate = self
    viewModel.meScored
      .map { items in
        return [RateHistorySectionModel(items: items, title: "", id: "id")]
      }
      .bind(to: scoredMeTable.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    
    scoredMeTable.rx
      .modelDeleted(RateHistoryCellModel.self)
      .bind(to: deletedScore)
      .disposed(by: disposeBag)
    
    
    
    
    viewModel.scoredByMe.bind { [unowned self] models in
      guard models.count == 0 else { return }
      UIView.animate(withDuration: 0.25) {
        self.scoredByMeEmpty.alpha = 1
      }
    }.disposed(by: disposeBag)
    
    
    viewModel.meScored.bind { [unowned self] models in
      guard models.count == 0 else { return }
      UIView.animate(withDuration: 0.25) {
        self.scoredMeEmpty.alpha = 1
      }
    }.disposed(by: disposeBag)
    
    
    
    
    
    viewModel.loading.drive(onNext : { [weak self] loading in
      DispatchQueue.main.async {
        if loading {
          self?.showActivityHUD()
        } else {
          self?.hideActivityHUD()
        }
      }
    }).disposed(by: disposeBag)
    
    viewModel.errorOccured.drive(onNext : { [weak self] error in
      DispatchQueue.main.async {
        self?.showErrorToast(with: error)
      }
    }).disposed(by: disposeBag)


  }
}

// MARK: - Constraints
extension ProfileModule.RateHistory.ViewController:UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Hide") { (action, indexPath) in
          tableView.dataSource?.tableView!(tableView, commit: .delete, forRowAt: indexPath)
        }
        delete.backgroundColor = UIColor.red
        return [delete]
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
         return UITableView.automaticDimension
     }

     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return UITableView.automaticDimension
     }

     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         cell.layoutIfNeeded()
     }
    
    
  func setupConstraints() {
    view.backgroundColor = .white
    view.addSubview(segment)
    view.addSubview(scoredByMeTable)
    view.addSubview(scoredMeTable)
    
    view.addSubview(scoredMeEmpty)
    view.addSubview(scoredByMeEmpty)

    scoredMeEmpty.makeAnchors { make in
      make.centerX(equalTo: scoredMeTable.centerX)
      make.centerY(equalTo: scoredMeTable.centerY)
    }
    
    scoredByMeEmpty.makeAnchors { make in
      make.centerX(equalTo: scoredByMeTable.centerX)
      make.centerY(equalTo: scoredByMeTable.centerY)
    }

    segment.makeAnchors { make in
      make.trailing(equalTo: view.trailing, constant: -6)
      make.top(equalTo: view.safeTop, constant: 6)
      make.leading(equalTo: view.leading, constant: 6)
    }
    
    scoredMeTable.makeAnchors { make in
      make.width(equalTo: view.width)
      make.top(equalTo: segment.bottom, constant: 6)
      make.bottom(equalTo: view.safeBottom)
    }
    
    scoredMeTableLeading = scoredByMeTable.leading(equalTo: view.leading, constant: 0)
    scoredMeTableLeading.isActive = true
    
    scoredByMeTable.makeAnchors { make in
      make.width(equalTo: view.width)
      make.top(equalTo: segment.bottom, constant: 6)
      make.bottom(equalTo: view.safeBottom)
      make.leading(equalTo: scoredMeTable.trailing)
    }
  }
}
