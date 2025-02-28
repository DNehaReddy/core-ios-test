import Foundation

public  class ErrorHandler {
    
    public var dispatchNucleusEvent: NucleusState
    
    public init(nucleusState: NucleusState) {
        self.dispatchNucleusEvent = nucleusState
    }
    
    public func processEvent(nucleusState: NucleusState) {
        guard let eventName = nucleusState.data["event_name"] as? String else {
            return
        }
                
        self.dispatchNucleusEvent = nucleusState  // Update with the latest state
        let timestamp = nucleusState.data["viewer_timestamp"] as? Int ?? 0
        switch eventName {
            case "timeUpdate", "pulseStart", "pulseEnd":
                 handleCurrentPosition()

            default:
                break
        }
    }
    
    public func handleCurrentPosition() {
            let currentPlayheadTime = self.dispatchNucleusEvent.getCurrentPlayheadTime()
            if (currentPlayheadTime != 0) {
                self.dispatchNucleusEvent.data["player_playhead_time"] = currentPlayheadTime
                self.dispatchNucleusEvent.data["view_max_playhead_position"] = max((self.dispatchNucleusEvent.data["view_max_playhead_position"] as? Int ?? 0) , currentPlayheadTime)
            } else {
                self.dispatchNucleusEvent.data["player_playhead_time"] = 0
            }
    }
}

