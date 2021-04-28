
import UIKit
import RxSwift
import RxCocoa

extension Score {
  class List {}
}

extension Score.List {
  class ViewController: BaseViewController {
    // MARK: - subviews
    let table: UITableView = {
      let view = UITableView()
      view.round()
      view.isScrollEnabled = false
      view.separatorInset = .zero
      view.backgroundColor = .white
      view.register(Score.List.Cell.self, forCellReuseIdentifier:   Score.List.Cell.reuseIdentifier)
      return view
    }()
    var tableConstraint: NSLayoutConstraint!
    
    var sizer = PublishSubject<Void>()

    let done = Components.button(text: L10n.Scoring.score)
    
    // MARK: - data && rx
    let disposeBag = DisposeBag()
    var viewModel: ViewModel!
    let occupancyType = BehaviorSubject<OccupancyType>(value: .team)
    
    // MARK: - lifecycle
    override func viewDidLoad() {
      super.viewDidLoad()
      setupConstraints()
      setupViewModelInput()
      setupViewModelOutput()
        
    }
  }
}

// MARK: - Data
extension Score.List.ViewController {
  func setupViewModelInput() {
    let bindings = Score.List.ViewModel.Bindings(
      done: done.rx.tap.asDriver()
    )
    viewModel.configure(with: bindings)
  }
  
  func setupViewModelOutput() {
    viewModel
      .models
      .asObservable()
      .bind(
      to: table.rx.items(
        cellIdentifier: Score.List.Cell.reuseIdentifier,
        cellType: Score.List.Cell.self)
    ) { row, model, cell in
      cell.setup(model: model)
      cell.value.bind { [weak model = model] value in
        model?.evaluated = Double(value)
      }
      .disposed(by: cell.disposeBag)
    }
    .disposed(by: disposeBag)
    
    sizer.bind { [unowned self] _ in
      self.tableConstraint.constant = self.table.contentSize.height
      UIView.animate(withDuration: 0.25) {
        self.table.layoutIfNeeded()
      }
    }
    .disposed(by: disposeBag)
    
    viewModel
      .models
      .asObservable()
      .delay(.milliseconds(1), scheduler: MainScheduler.instance)
      .bind { [unowned self] _ in
        self.sizer.onNext(())
      }
      .disposed(by: disposeBag)

    viewModel
      .models
      .asObservable()
      .mapToVoid()
      .delay(.seconds(1), scheduler: MainScheduler.instance)
      .bind { [unowned self] _ in
        self.sizer.onNext(())
      }
      .disposed(by: disposeBag)

    table.rx
      .modelSelected(Score.ScoreElem.self)
      .bind { [unowned self] model in
        let cells = self.table.visibleCells
        let typedCells = cells.compactMap { cell -> Score.List.Cell? in
          return cell as? Score.List.Cell
        }
        let neededCell = typedCells.first { cell -> Bool in
          return cell.title.text == model.question.name
        }
        
        if let cell = neededCell {
          if cell.isHiddenAdditional{
            cell.showAdditional()
          } else {
            cell.hideAdditional()
          }
        }
        
   
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(25)) { [weak self] in
          self?.sizer.onNext(())
        }
        
        
        self.table.beginUpdates()
        self.table.endUpdates()
        
        
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - Constraints
extension Score.List.ViewController {
  func setupConstraints() {
    view.backgroundColor = Colors.screenBg
    let scrollView = UIScrollView()
    scrollView.autoresizingMask = .flexibleHeight
    scrollView.backgroundColor = Colors.screenBg
    
    scrollView.fullSafe(in: view)

    let tableOffset: CGFloat = -16 - 44 - 16 // offset for button done
    scrollView.addSubview(table)
    table.makeAnchors { make in
      make.top(equalTo: scrollView.top, constant: 16)
      make.width(equalTo: scrollView.width, constant: -32)
      make.bottom(equalTo: scrollView.bottom, constant: tableOffset)
      make.leading(equalTo: scrollView.leading, constant: 16)
      make.trailing(equalTo: scrollView.trailing, constant: -16)
    }

    view.addSubview(done)
    done.makeAnchors { make in
      make.leading(equalTo: view.leading, constant: 16)
      make.trailing(equalTo: view.trailing, constant: -16)
      make.bottom(equalTo: view.safeBottom, constant: -16)
    }
    
    tableConstraint = table.height(1)
    tableConstraint.isActive = true
  }
}
