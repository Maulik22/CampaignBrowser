import UIKit
import RxSwift

/**
 The view which displays the list of campaigns. It is configured in the storyboard (Main.storyboard). The corresponding
 view controller is the `CampaignsListingViewController`.
 */
class CampaignListingView: UICollectionView {

    /**
     A strong reference to the view's data source. Needed because the view's dataSource property from UIKit is weak.
     */
    @IBOutlet var strongDataSource: UICollectionViewDataSource!

    /**
     All the possible cell types that are used in this collection view.
     */
    enum Cells: String {

        /** The cell which is used to display the loading indicator. */
        case loadingIndicatorCell

        /** The cell which is used to display a campaign. */
        case campaignCell
        
        /** The cell which is used to display an error screen. */
        case errorCell
    }

    /**
     Displays the given campaign list.
     */
    func display(campaigns: CampaignList) {
        let campaignDataSource = ListingDataSource(campaigns: campaigns)
        dataSource = campaignDataSource
        delegate = campaignDataSource
        strongDataSource = campaignDataSource
        reloadData()
    }
    
    /**
     Displays loading screen.
     */
    func showLoadingScreen() {
        let loadingDataSource = LoadingDataSource()
        dataSource = loadingDataSource
        delegate = loadingDataSource
        strongDataSource = loadingDataSource
        reloadData()
    }
    
    /**
     Displays Error screen when an error is recorded.
     */
    func showErrorScreenIn(campaignListingViewController: CampaignListingViewController?) {
        let errorDataSource = ErrorDataSource(campaignListingViewController: campaignListingViewController)
        dataSource = errorDataSource
        delegate = errorDataSource
        strongDataSource = errorDataSource
        reloadData()
    }
    
}


/**
 The data source for the `CampaignsListingView` which is used to display the list of campaigns.
 */
class ListingDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    /** The campaigns that need to be displayed. */
    let campaigns: [Campaign]

    /**
     Designated initializer.

     - Parameter campaign: The campaigns that need to be displayed.
     */
    init(campaigns: [Campaign]) {
        self.campaigns = campaigns
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return campaigns.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let campaign = campaigns[indexPath.item]
        let reuseIdentifier =  CampaignListingView.Cells.campaignCell.rawValue
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let campaignCell = cell as? CampaignCell {
            campaignCell.moodImage = campaign.moodImage
            campaignCell.name = campaign.name
            campaignCell.descriptionText = campaign.description
        } else {
            assertionFailure("The cell should a CampaignCell")
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 450)
    }

}


/**
 The data source for the `CampaignsListingView` which is used while the actual contents are still loaded.
 */
class LoadingDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = CampaignListingView.Cells.loadingIndicatorCell.rawValue
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        /** Show and animate activityIndicator till we get campaigns list/error */
        let activityIndicator: UIActivityIndicatorView? = cell.viewWithTag(20) as? UIActivityIndicatorView
        activityIndicator?.startAnimating()

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}


/**
 The data source for the `CampaignsListingView` which is used while any kind of error is recorded.
 */
class ErrorDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /** The viewcontroller where error screen needs to be displayed. */
    let campaignListingViewController: CampaignListingViewController?
    
    /**
     Designated initializer.
     
     - Parameter campaignListingViewController:
     */
    init(campaignListingViewController: CampaignListingViewController?) {
        self.campaignListingViewController = campaignListingViewController
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reuseIdentifier = CampaignListingView.Cells.errorCell.rawValue
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        /** Button which will try to load campaigns list on tap */
        let button: UIButton? = cell.viewWithTag(22) as? UIButton
        button?.addTarget(campaignListingViewController, action: #selector(CampaignListingViewController.tryToLoadCampaignList), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
}
