import Foundation

typealias EventMetaData = [String: Any]

public  class PlybackPulseHadler {
    public var dispatchNucleusEvent: NucleusState
    public var tokenId: String?
    public var actionableData: [String: Any]?
    public var sdkDetails: [String: Any]
    public var userData: [String: Any]
    public var previousBeaconData: [String: Any]?
    public var previousVideoState: [String: Any] = [:]
    public var eventDispatcher: ConnectionHandler?
    public var getFastPixAPI: String?
    public var keyParams: [String] = [
        "workspace_id",
        "view_id",
        "view_sequence_number",
        "player_sequence_number",
        "beacon_domain",
        "player_playhead_time",
        "viewer_timestamp",
        "event_name",
        "video_id",
        "player_instance_id",
      ];
    public var eventHandler = ["viewBegin", "error", "ended", "viewCompleted"];
    
    public init(nucleusState: NucleusState) {
        self.dispatchNucleusEvent = nucleusState
        self.actionableData = nucleusState.metadata
        self.tokenId = nucleusState.metadata["workspace_id"] as? String
        self.previousBeaconData = nil
        self.sdkDetails = [
                    "fastpix_embed" : "fastpix-ios-core",
                    "fastpix_embed_version" : "1.0.0",
        ]
        self.userData = FastPixUserDefaults.getViewerCookie()
        
        self.getFastPixAPI = formulateBeaconUrl(workspace: self.tokenId ?? "", config: self.actionableData ?? [:])
        self.eventDispatcher = ConnectionHandler(api: self.getFastPixAPI ?? "")
    }
    
    public func sendData(event: String, eventAttr: [String: Any]) {
        
        if  eventAttr["view_id"] != nil {
            
            let sessionData = FastPixUserDefaults.updateCookies()
            let mergedData = mergeDictionaries(
                self.sdkDetails,
                eventAttr,
                sessionData,
                self.userData,
                [
                    "event_name": event,
                    "workspace_id": self.tokenId ?? ""
                ]
            )
            
            let cloneBeaconObj = cloneBeaconData(eventName: event, dataObj: mergedData) ?? [:]
            let formattedEvent = ConvertEventNamesToKeys.formatEventData(cloneBeaconObj)
            
            if (self.tokenId != nil) {
                self.eventDispatcher?.scheduleEvent(data: formattedEvent)
                
                if (event == "viewCompleted") {
                    self.eventDispatcher?.destroy(onDestroy: true)
                } else if (eventHandler.contains(event)) {
                    self.eventDispatcher?.processEventQueue()
                }
            }
        }
    }
    
    public func destroy() {
        self.eventDispatcher?.destroy(onDestroy: false)
    }
    
    func cloneBeaconData(eventName: String, dataObj: [String: Any]) -> [String: Any]? {
            var clonedObj: [String: Any] = [:]

            if eventName == "viewBegin" || eventName == "viewCompleted" {
                clonedObj = dataObj

                if eventName == "viewCompleted" {
                    previousBeaconData = nil
                }
                previousBeaconData = clonedObj
            } else {
                for param in keyParams {
                    if let value = dataObj[param] {
                        clonedObj[param] = value
                    }
                }

                if let trimmedState = getTrimmedState(currentData: dataObj) {
                    for (key, value) in trimmedState {
                        clonedObj[key] = value
                    }
                }

                if ["requestCompleted", "requestFailed", "requestCanceled"].contains(eventName) {
                    for (key, value) in dataObj {
                        if key.hasPrefix("request") {
                            clonedObj[key] = value
                        }
                    }
                }

                if eventName == "variantChanged" {
                    for (key, value) in dataObj {
                        if key.hasPrefix("video_source") {
                            clonedObj[key] = value
                        }
                    }
                }
                previousBeaconData = clonedObj
            }

            return clonedObj
        }

        func getTrimmedState(currentData: [String: Any]) -> [String: Any]? {
            guard let previousData = previousBeaconData else {
                previousBeaconData = currentData
                return currentData
            }

            if !NSDictionary(dictionary: previousData).isEqual(to: currentData) {
                var trimmedData: [String: Any] = [:]

                for (key, value) in currentData {
                    if previousVideoState[key] as? NSObject != value as? NSObject {
                        trimmedData[key] = value
                    }
                }

                previousVideoState = currentData
                return trimmedData
            }
            return [:]
        }

    public func mergeDictionaries(_ dictionaries: [String: Any]...) -> [String: Any] {
        var mergedDictionary: [String: Any] = [:]
        
        for dictionary in dictionaries {
            for (key, value) in dictionary {
                if !(value is NSNull) {
                    mergedDictionary[key] = value
                }
            }
        }
        
        return mergedDictionary
    }
    
    public func formulateBeaconUrl(workspace: String, config: [String: Any]) -> String {
        let beaconDomain = config["beaconDomain"] as? String ?? "metrix.guru"
        let finalWorkspace = workspace.isEmpty ? "collector" : workspace
        return "https://\(finalWorkspace).\(beaconDomain)"
    }
}
