//
//  ProductListCoordinator.swift
//  MiniPedia
//
//  Created by Agus Cahyono on 12/10/20.
//  Copyright © 2020 Agus Cahyono. All rights reserved.
//

import RxSwift

class ProductListCoordinator: ReactiveCoordinator<Void> {
    
    let rootViewController: UIViewController
    public var viewModel = ProductListViewModel()
    
    init(rootViewController: UIViewController, query: QueryProduct?) {
        self.rootViewController = rootViewController
        if let query = query {
            viewModel.queryProduct = query
        }
    }
    
    override func start() -> Observable<Void> {
        
        let viewController          = ProductListView()
        viewController.viewModel    = viewModel
        viewController.hidesBottomBarWhenPushed = true
        rootViewController.navigationController?
            .pushViewController(viewController, animated: true)
        
        viewModel.selectedProduct
            .flatMap( { [unowned self] (product) in
                return self.coordinateToProductDetail(with: product)
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        viewModel.cartButtonDidTap
            .flatMapLatest({ [unowned self] _ in
                return self.coordinateToCart()
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        viewModel.backButtonDidTap
            .subscribe(onNext: { [unowned self] _ in
                self.rootViewController.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.filterButtonDidTap
            .flatMap( { [unowned self] bind in
                return self.coordinateToProductFilter(bind)
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        
        return Observable.never()
        
    }
    
    private func coordinateToProductDetail(with productViewModel: ProductListCellViewModel) -> Observable<Void> {
        let productDetailCoordinator = ProductDetailCoordinator(rootViewController: rootViewController)
        productDetailCoordinator.viewModel = productViewModel
        return coordinate(to: productDetailCoordinator)
            .map { _ in () }
    }
    
    private func coordinateToCart() -> Observable<Void> {
        self.rootViewController.navigationController?.popToRootViewController(animated: true)
        Delay.wait(delay: 1) {
            self.rootViewController.tabBarController?.selectedIndex = 1
        }
        return Observable.never().take(1)
    }
    
    private func coordinateToProductFilter(_ binding: ProductFilterBinding) -> Observable<Void> {
        let filterCoordinator = ProductFilterViewCoordinator(rootViewController: rootViewController, delegate: binding.delegate, filter: binding.filter)
        return coordinate(to: filterCoordinator)
            .map { _ in () }
    }
    
}
