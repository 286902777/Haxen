//
//  MovieVideoModel.swift
//  HookMemory
//
//  Created by HF on 2023/11/20.
//

import Foundation

class MovieVideoModel: BaseModel {
    var id: String = ""
    
    var isImport: Bool = false
    
    var isMovie: Bool = true
    
    var title: String = ""
    
    var videoInfo: String = ""
    
    var country: String = ""
    
    var ssn_eps: String = ""
    
    var ssn_id: String = ""
    
    var eps_id: String = ""
    
    var eps_name: String = ""
    
    var ssn_name: String = ""
    
    var eps_num: Int = 1
    
    var rate: String = ""
    
    var url: String = ""
    
    var path: String = ""
    
    var coverImageUrl: String = ""
    
    var uploadTime: String = ""
    
    var totalTime: Double = 0
    
    var playedTime: Double = 0
    
    var playProgress: Double = 0
    
    var dataSize: String = ""
    
    var updateTime: Double = 0
    
    var format: String = ""
    
    var captions:[MovieCaption] = []
}

public class MovieCaption: NSObject, NSSecureCoding{
    public static var supportsSecureCoding: Bool {
        return true
    }
    public var captionId: String = ""
    
    public var name: String = ""
    
    public var short_name: String = ""
    
    public var display_name: String = ""
    
    public var original_address: String = ""
    
    public var transferred_address: String = ""
    
    public var local_address: String = ""
    
    public var isSelect: Bool = false
     // 编码成object
    public func encode(with coder: NSCoder) {
        coder.encode(captionId, forKey: "video_captionId")
        coder.encode(name, forKey: "video_name")
        coder.encode(short_name, forKey: "short_name")
        coder.encode(display_name, forKey: "display_name")
        coder.encode(original_address, forKey: "original_address")
        coder.encode(transferred_address, forKey: "transferred_address")
        coder.encode(local_address, forKey: "local_address")
    }
    
    public required init?(coder: NSCoder) {
        captionId = (coder.decodeObject(of: [NSString.self], forKey: "video_captionId") as? String) ?? ""
//        captionId = (coder.decodeObject(forKey: "video_captionId") as? String) ?? ""
        name = (coder.decodeObject(of: [NSString.self], forKey: "video_name") as? String) ?? ""
        short_name = (coder.decodeObject(of: [NSString.self], forKey: "short_name") as? String) ?? ""
        display_name = (coder.decodeObject(of: [NSString.self], forKey: "display_name") as? String) ?? ""
        original_address = (coder.decodeObject(of: [NSString.self], forKey: "original_address") as? String) ?? ""
        transferred_address = (coder.decodeObject(of: [NSString.self], forKey: "transferred_address") as? String) ?? ""
        local_address = (coder.decodeObject(of: [NSString.self], forKey: "local_address") as? String) ?? ""
    }
    
    public override init() {
        super.init()
    }
}


class MovieVideoInfoDataModel: BaseModel {
    var ssn_list: [MovieVideoInfoSsnlistModel] = []
    var genre_dict = [MovieGenreModel]()
    var comments = MovieComments()
    var play_addr = ""
    var mflx_vid = ""
    var year = ""
    var cover = ""
    var lang = ""
    var country = ""
    var m_type = ""
    var id = ""
    var title = ""
    var description = ""
    var storyline = ""
    var drirector = ""
    var writer = ""
    var stars = ""
    var mflx_rq = ""
    var rate = ""
    var pub_date = ""
    var tags = ""
    var duration = ""
    var views = ""
    var length = ""
    var next_epsdate = ""
    var casts: [MovieCastsModel] = []
    var source = ""
    var source_link = ""
    var status = ""
    var mflx_url = ""
    var quality = ""
    var board = ""
    var board_id_1 = ""
    var board_id_2 = ""
    var rq = ""
    
    class MovieGenreModel: BaseModel {
        var title = ""
        var id = ""
    }
    
    class MovieCastsModel: BaseModel {
        var cover = ""
        var title = ""
        var id = ""
    }
    
    
    class MovieComments: BaseModel {
        var list: [MovieCommentList] = []
        var len_raw = 0
        var len = 0
        var word: [String] = []
    }
    
    class MovieCommentList: BaseModel {
        var liked = ""
        var likes = ""
        var more = ""
        var up = 0
        var content = ""
        var cover = ""
        var date = ""
        var id = 0
        var v_id = 0
        var uname = ""
        var vp = ""
        var del = 0
        var uid = 0
    }
}

class MoviemslInfoModel: BaseModel {
    var data: [MovieMslDataModel] = []
}

class MovieVideoInfoData2Model: BaseModel {
    var name: String = ""
    var data: [MovieDataInfoModel] = []
    var order: Int = 0
    var display_type: Int = 0
    var secname: String = ""
    var data_type: Int = 0
    var video_flag: Int = 0
}

class MovieVideoInfoData3Model: BaseModel {
    var ymsl_info: MoviemslInfoModel = MoviemslInfoModel()
}

class MovieMslDataModel: BaseModel {
    var country = ""
    var title = ""
    var param5 = ""
    var drirector = ""
    var storyline = ""
    var param1 = ""
    var description = ""
    var status = ""
    var like = ""
    var tags = ""
    var mflx_url = ""
    var m_type = ""
    var unlike = ""
    var ss_eps = ""
    var param2 = ""
    var age_rate = ""
    var rate = ""
    var param9 = ""
    var cover = ""
    var param8 = ""
    var m_type_2 = ""
    var lang = ""
    var stars = ""
    var param6 = ""
    var source = ""
    var views = ""
    var source_link = ""
    var param10 = ""
    var pub_date = ""
    var param4 = ""
    var id = ""
    var param3 = ""
    var quality = ""
    var length = ""
    var param7 = ""
    var writer = ""
}

class MovieVideoInfoSSNModel: BaseModel {
    var ssn_list: [MovieVideoInfoSsnlistModel] = []
    var epss: [MovieVideoInfoEpssModel] = []
}

class MovieVideoInfoEpssModel: BaseModel {
    var title = ""
    var id = ""
    var eps_num: Int = 0
    var isSelect: Bool = false
}

class MovieTVEpsListModel: BaseModel {
    var eps_list: [MovieVideoInfoEpssModel] = []
}


class MovieTVSeasonModel: BaseModel {
    var data:[MovieVideoInfoSsnlistModel] = []
}

class MovieTVSSNModel: BaseModel {
    var data = MovieTVEpsListModel()
}

class MovieVideoInfoSsnlistModel: BaseModel {
    var id = ""
    var title = ""
    var isSelect: Bool = false
}
class MTPlayLinkModel: BaseModel {
    var source_type_ordinal = 0
    var play_address = ""
    var transferred = 0
    var source_key = ""
    var source_sequence = ""
}

class MovieCaptionModel: BaseModel {
    var display_name = ""
    var id = ""
    var original_address = ""
    var short_name = ""
    var transferred_address = ""
    var name = ""
}

class MovieCaptionListModel: BaseModel {
    var data: [MovieCaptionModel] = []
}
class MovieDownloaderCaptionModel: BaseModel {
    var data: MovieSubtitleListModel = MovieSubtitleListModel()
}

class MovieSubtitleListModel: BaseModel {
    var subtitle: [MovieSubtitleModel] = []
}

class MovieSubtitleModel: BaseModel {
    var sub = ""
    var l_display = ""
    var l_short = ""
    var t_name = ""
    var lang = ""
}

class MoviePremiuModel: BaseModel {
    var auto_renew_status: String {
        return entity.pending_renewal_info.first?.auto_renew_status ?? "0"
    }
    var entity: MTPremiuEntityModel = MTPremiuEntityModel()
    var expires_date_ms: TimeInterval {
        return entity.latest_receipt_info.first?.expires_date_ms ?? 0
    }
    var product_id: String {
        return entity.latest_receipt_info.first?.product_id ?? ""
    }
    var checks: [String] = []
}

class MTPremiuEntityModel: BaseModel {
    var receipt = ""
    var environment = ""
    var status = 0
    var latest_receipt_info: [MovieReceiptInfo] = []
    var device_id = ""
    var ok: Bool = false
    var pending_renewal_info: [MoviePendingRenewalInfo] = []
}

class MovieReceiptModel: BaseModel {
    var version_external_identifier = 0
    var receipt_creation_date = ""
    var receipt_creation_date_ms: TimeInterval = 0
    var receipt_creation_date_pst = ""
    var adam_id = 0
    var app_item_id = 0
    var in_app: [MovieReceiptInfo] = []
    var bundle_id = ""
    var application_version = ""
    var download_id = 0
    var original_purchase_date_ms: TimeInterval = 0
    var original_purchase_date = ""
    var request_date = ""
    var receipt_type = ""
    var original_purchase_date_pst = ""
    var original_application_version = ""
    var request_date_ms: TimeInterval = 0
    var request_date_pst = ""
}

class MovieReceiptInfo: BaseModel {
    var transaction_id = ""
    var original_transaction_id = ""
    var quantity = ""
    var product_id = ""
    var is_trial_period = ""
    var is_in_intro_offer_period = ""
    var original_purchase_date_pst = ""
    var expires_date_ms: TimeInterval = 0
    var expires_date = ""
    var expires_date_pst = ""
    var web_order_line_item_id = ""
    var subscription_group_identifier = ""
    var in_app_ownership_type = ""
    var purchase_date_pst = ""
    var original_purchase_date_ms: TimeInterval = 0
    var original_purchase_date = ""
    var purchase_date_ms: TimeInterval = 0
    var purchase_date = ""
}

class MoviePendingRenewalInfo: BaseModel {
    var auto_renew_status = ""
    var original_transaction_id = ""
}

class MovieVideoInfoModel: BaseModel {
    var data = MovieVideoInfoDataModel()
    var data_2:[MovieVideoInfoData2Model] = []
    var data_3 = MovieVideoInfoData3Model()
    var ssn = MovieVideoInfoSSNModel()
}

class MoviePlayLinkModel: BaseModel {
    var play_address = ""
    var source_sequence = ""
    var source_key = ""
    var transferred = 0
    var source_type_ordinal = 0
}
