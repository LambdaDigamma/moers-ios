//
//  ITDPointTest.swift
//  
//
//  Created by Lennart Fischer on 26.12.22.
//

import Foundation
import XMLCoder
import XCTest
@testable import EFAAPI

final class ITDPointTest: XCTestCase {
    
    func test_decoding_geoobject() throws {
        
        let dataString = """
<itdPoint stopID="20036653" area="90" platform="1" gid="de:05170:36653" areaGid="de:05170:36653:90" pointGid="de:05170:36653:90:DB1" name="Alpen Bahnhof" nameWO="" place="Alpen" platformName="" usage="" x="6.51816" y="51.58328" mapName="WGS84[DD.DDDDD]" omc="5170004" placeID="1" arrValid="0" depValid="0" arrDelay="0" depDelay="0"><genAttrList><genAttrElem><name>STOP_MEANS</name><value>161</value></genAttrElem><genAttrElem><name>STOP_MAJOR_MEANS</name><value>6</value></genAttrElem><genAttrElem><name>AREA_NIVEAU_DIVA</name><value>0</value></genAttrElem></genAttrList><itdDateTime><itdDate year="0" month="0" day="0" weekday="-1"/><itdTime hour="0" minute="0" second="0"/></itdDateTime></itdPoint>
"""
        
        let decoder = XMLDecoder()
        
        let point = try decoder.decode(ITDPoint.self, from: dataString.data(using: .utf8)!)
        
        print(point)
        
    }
    
}
