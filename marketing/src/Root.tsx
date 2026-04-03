import React from "react";
import { Still } from "remotion";
import {
  FestivalPromo,
  festivalAppStoreStills,
} from "./components/FestivalPromo";
import { iPhone17Pro } from "./apple-screenshot-sizes";
import { setRemotionImageLoader } from "./components/PhoneFrame";

// Initialize Remotion image loader
setRemotionImageLoader();

export const RemotionRoot: React.FC = () => {
  // iPhone 17 Pro carousel dimensions: 4 screenshots + 3 dead zones
  const promoWidth = iPhone17Pro.portrait.width * 4 + 20 * 3;
  const promoHeight = iPhone17Pro.portrait.height;

  return (
    <>
      {/* Promotional composition ON iPhone 17 Pro canvas with device frames */}
      <Still
        id="festival-promo"
        component={FestivalPromo}
        width={promoWidth}
        height={promoHeight}
        defaultProps={{ backgroundImage: undefined }}
      />

      {/* App Store stills - Use these for actual App Store submission */}
      {/* These have the dead zone overlays for proper screenshot spacing */}
      <Still
        id={festivalAppStoreStills.iphone17Pro.id}
        component={festivalAppStoreStills.iphone17Pro.component}
        width={festivalAppStoreStills.iphone17Pro.width}
        height={festivalAppStoreStills.iphone17Pro.height}
        defaultProps={festivalAppStoreStills.iphone17Pro.defaultProps}
      />

      <Still
        id={festivalAppStoreStills.iphone14Plus.id}
        component={festivalAppStoreStills.iphone14Plus.component}
        width={festivalAppStoreStills.iphone14Plus.width}
        height={festivalAppStoreStills.iphone14Plus.height}
        defaultProps={festivalAppStoreStills.iphone14Plus.defaultProps}
      />

      <Still
        id={festivalAppStoreStills.iphone8Plus.id}
        component={festivalAppStoreStills.iphone8Plus.component}
        width={festivalAppStoreStills.iphone8Plus.width}
        height={festivalAppStoreStills.iphone8Plus.height}
        defaultProps={festivalAppStoreStills.iphone8Plus.defaultProps}
      />

      <Still
        id={festivalAppStoreStills.ipadPro.id}
        component={festivalAppStoreStills.ipadPro.component}
        width={festivalAppStoreStills.ipadPro.width}
        height={festivalAppStoreStills.ipadPro.height}
        defaultProps={festivalAppStoreStills.ipadPro.defaultProps}
      />
    </>
  );
};
