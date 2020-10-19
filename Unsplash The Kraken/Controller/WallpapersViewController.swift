//
//  WallpapersViewController.swift
//  Unsplash The Kraken
//
//  Created by Andre Elandra on 17/09/20.
//  Copyright © 2020 Andre Elandra. All rights reserved.
//

import UIKit
import Network

class WallpapersViewController: UIViewController {
    //MARK: - Private Properties
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let searchBar = UISearchBar()
    private var searchBarButtonItem = UIBarButtonItem()
    
    private var unsplashManager = UnsplashManager()
    private let wallpapersViewLayout = WallpapersViewLayout()
    private let monitor = NWPathMonitor()
    
    private var resultArray: [Photo]? = []
    private var searchResultArray: [String]? = []
    private var heightArray: [CGFloat]? = []
    
    private var totalPage = 0
    private var userPage = UserDefaults.standard.integer(forKey: K.userPageKey)
    private var userQuery = ""
    private var userDidSearch = false
    private var lowDataMode = false
    private var normalMode = false
    
    //MARK: - Internal Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitFetch()
        setupUI()
        startMonitoring()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsUpdateOfHomeIndicatorAutoHidden()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    func setupInitFetch() {
        searchResultArray?.removeAll()
        unsplashManager.delegate = self
        unsplashManager.fetchSearchResult(from: K.randomQuery, page: Int.random(in: 1...10))
        userQuery = K.randomQuery
        userPage = 1
    }
    
    func setupUI() {
        setupNavBar()
        setupSearchBar()
        setupCollectionView()
    }
    
    func setupNavBar() {
        let navigationBar = navigationController?.navigationBar
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.backgroundColor = UIColor(named: K.themeColor)
        navigationBar?.standardAppearance = navigationBarAppearance
        navigationBar?.compactAppearance = navigationBarAppearance
        navigationBar?.scrollEdgeAppearance = navigationBarAppearance
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = K.searchBarTextFieldPlaceholder
        searchBar.searchBarStyle = .minimal
        if let cancelColor = UIColor(named: K.themeInvertedColor){
            let attributes:[NSAttributedString.Key: Any] = [.foregroundColor:cancelColor]
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        }
        searchBarButtonItem = navigationItem.rightBarButtonItem!
    }
    
    func setupCollectionView() {
        if let layout = collectionView.collectionViewLayout as? WallpapersViewLayout {
            layout.delegate = self
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.register(UINib(nibName: K.wallpapersNibName, bundle: .main), forCellWithReuseIdentifier: K.reuseCellID)
        collectionView.reloadData()
    }
    
    @IBAction func searchButtonPressed(sender: AnyObject) {
        showSearchBar()
    }
    
    func showSearchBar() {
        navigationItem.titleView = searchBar
        
        searchBar.alpha = 0
        searchBar.tintColor = .gray
        searchBar.showsCancelButton = true
        
        navigationItem.setRightBarButton(nil, animated: true)
        
        self.searchBar.becomeFirstResponder()
        UIView.animate(withDuration: 0.5, animations: { [self] in
            navigationItem.title = ""
            searchBar.alpha = 1
        }, completion: nil)
    }
    
    func hideSearchBar() {
        searchBar.showsCancelButton = false
        
        navigationItem.title = ""
        navigationItem.setRightBarButton(searchBarButtonItem, animated: true)
        
        UIView.animate(withDuration: 0.2, animations: { [self] in
            navigationItem.titleView = nil
        }, completion: { [self] _ in
            navigationItem.title = K.title
            view.endEditing(true)
        })
        
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [self] path in
            normalMode = path.isConstrained ? false : true
            lowDataMode = path.isConstrained ? true : false
        }
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }
    
    func isLandscape() -> Bool {
        return self.view.frame.width > self.view.frame.height
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == K.previewSegueID {
            let destination = segue.destination as! PreviewViewController
            if let safeResultArray = self.resultArray {
                destination.resultArray = safeResultArray
            }
            if let indexPath = sender as? IndexPath {
                destination.index = indexPath.item
                destination.username = self.resultArray?[indexPath.item].user?.username
                destination.lowDataMode = self.lowDataMode
                let backItem = UIBarButtonItem()
                backItem.title = K.backTitle
                destination.navigationItem.backBarButtonItem = backItem
            }
        }
        
    }
    
}

//MARK: - Search Bar Delegate
extension WallpapersViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let searchText = searchBar.text {
            if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                searchBar.searchTextField.placeholder = K.emptySearchBarTextFieldPlaceholder
            } else {
                hideSearchBar()
                searchBar.searchTextField.placeholder = searchText
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    searchBar.searchTextField.placeholder = K.searchBarTextFieldPlaceholder
                }
                resetData(with: searchBar)
                setupUserSearch(from: searchText)
            }
        }
        
    }
    
    func resetData(with searchBar: UISearchBar) {
        resultArray?.removeAll()
        searchResultArray?.removeAll()
        heightArray?.removeAll()
        searchBar.searchTextField.text = ""
    }
    
    func setupUserSearch(from searchText: String) {
        let query = searchText.replacingOccurrences(of: " ", with: "%20")
        userQuery = query
        userPage = 1
        unsplashManager.fetchSearchResult(from: userQuery, page: userPage)
        searchBar.searchTextField.text = ""
        view.endEditing(true)
        userDidSearch = true
        displayAlert(title: nil, message: K.Alert.searchedMessage, style: .alert, action: .offWithIndicator)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        hideSearchBar()
    }
    
}

//MARK: - Collection View Delegate
extension WallpapersViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.previewSegueID, sender: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            if let id = self.resultArray?[indexPath.item].id {
                let save = UIAction(title: K.Alert.save, image: UIImage(systemName: K.Alert.saveImage)) { _ in
                    self.unsplashManager.fetchDownload(id: id)
                }
                let menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: [save])
                return menu
            }
            return nil
        }
        return config
        
    }
    
}

//MARK: - Collection View Data Source
extension WallpapersViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            if indexPath.item + 1 == self.searchResultArray?.count {
                self.userPage += 1
                self.unsplashManager.fetchSearchResult(from: self.userQuery, page: self.userPage)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchResultArray == nil {
            return 0
        } else {
            return searchResultArray!.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.reuseCellID, for: indexPath) as! WallpapersCollectionViewCell
        
        if !searchResultArray!.isEmpty {
            if let searchResultImage = searchResultArray?[indexPath.item] {
                if let url = URL(string: searchResultImage) {
                    cell.wallpaperImage.loadImage(from: url)
                    self.wallpapersViewLayout.prepare()
                }
            }
        }
        return cell
        
    }
    
    func scrollToFirstRow() {
        let indexPath = IndexPath(item: 0, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
}

//MARK: - Wallpapers Layout Delegate
extension WallpapersViewController: WallpapersLayoutDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat? {
        
        var height = heightArray?[indexPath.item] ?? 2500
        if height > 5000 {
            height = 5000
        }
        let newHeight = isLandscape() ? height * 0.06 : height * 0.1
        return newHeight
    }
    
    var columnNumber: Int {
        return isLandscape() ? 3 : 2
    }
    
}

//MARK: - Unsplash Delegate
extension WallpapersViewController: UnsplashDelegate {
    
    func didSearchUnsplash(_ unsplashManager: UnsplashManager, _ unsplashSearchModel: UnsplashSearchModel) {
        DispatchQueue.main.async {
            self.monitorNetworkModeForUnsplashData(from: unsplashSearchModel)
        }
    }
    
    func monitorNetworkModeForUnsplashData(from unsplashSearchModel: UnsplashSearchModel) {
        if lowDataMode == true {
            for result in unsplashSearchModel.photo {
                setupUnsplashData(result, urlString: result.urls?.thumb, height: result.height)
            }
            
        } else {
            for result in unsplashSearchModel.photo {
                setupUnsplashData(result, urlString: result.urls?.regular, height: result.height)
            }
        }
        
        totalPage = unsplashSearchModel.totalPages
        
        if userPage == totalPage {
            displayAlert(title: K.Alert.reachPageLimitTitle, message: K.Alert.reachPageLimitMessage, style: .alert, action: .default, actionTitle: K.Alert.ok, actionStyle: .default)
        }
        
        if userDidSearch == true {
            userDidSearch = false
            scrollToFirstRow()
        }
        
        collectionView.reloadData()
    }
    
    func setupUnsplashData(_ result: Photo, urlString: String?, height: Int?) {
        resultArray?.append(result)
        if let imageURL = urlString, let imageHeight = height  {
            heightArray?.append(CGFloat(imageHeight))
            searchResultArray?.append(imageURL)
        }
    }
    
    func didDownload(_ unsplashManager: UnsplashManager, _ unsplashDownloadModel: UnsplashDownloadModel) {
        
        if let data = try? Data(contentsOf: URL(string: unsplashDownloadModel.url)!) {
            if let newImage = UIImage(data: data) {
                UIImageWriteToSavedPhotosAlbum(newImage, self, #selector(updateStatus(image:error:contextInfo:)), nil)
            }
        }
        
    }
    
    @objc func updateStatus(image: UIImage, error: Error?, contextInfo: UnsafeRawPointer?) {
        if let err = error {
            displayAlert(title: K.Alert.error, message: err.localizedDescription, action: .default)
        } else {
            displayAlert(title: K.Alert.successTitle, message: K.Alert.successDownloadTitle, style: .alert, action: .download, actionTitle: K.Alert.ok, actionStyle: .default) { _ in
                UIApplication.shared.open(URL(string: K.photosAppURLScheme)!)
            }
        }
    }
    
    func didFailWithError(error: Error) {
        displayAlert(title: K.Alert.error, message: error.localizedDescription, action: .default)
    }
    
}
