import UIKit
import RxSwift


/**
 The view controller responsible for listing all the campaigns. The corresponding view is the `CampaignListingView` and
 is configured in the storyboard (Main.storyboard).
 */
class CampaignListingViewController: UIViewController {

    let disposeBag = DisposeBag()

    @IBOutlet
    private(set) weak var typedView: CampaignListingView!

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(typedView != nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tryToLoadCampaignList()
    }
    
    func tryToLoadCampaignList(){
        
        /** Show loading screen till we get campaign list. */
        self.typedView.showLoadingScreen()
        
        /** Load the campaign list and display it as soon as it is available. */
        ServiceLocator.instance.networkingService
            .createObservableResponse(request: CampaignListingRequest())
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] campaigns in
                self?.typedView.display(campaigns: campaigns)
                },onError: { [weak self] error in
                    
                    /** Error codes related to possible network failures ::
                       -1001 - The request timed out.
                       -1003 - A server with the specified hostname could not be found.
                       -1009 - The Internet connection appears to be offline.
                       -1200 - An SSL error has occurred and a secure connection to the server cannot be made.
                     */
                    if (error as NSError).code == -1001 || (error as NSError).code == -1003 || (error as NSError).code == -1009  || (error as NSError).code == -1200 {
                        self?.typedView.showErrorScreenIn(campaignListingViewController: self)
                    }
                    
                    print("Error recorded :: \(error.localizedDescription)")
                }
            )
            .addDisposableTo(disposeBag)
    }
}
