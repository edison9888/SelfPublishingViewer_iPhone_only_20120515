/*
 *  CVConstants.h
 *  CommonViewer
 *
 *  Created by FSCM100301 on 10/08/03.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#define userdataLastIndex								@"userdataLastIndex"
#define userdataBookmarkIndex							@"userdataBookmarkIndex"
#define userdataPageRememberMode						@"userdataPageRememberMode"
#define userdataPageAnimation							@"userdataPageAnimation"
#define userdataImageScale								@"userdataImageScale"
#define userdataTOCType									@"userdataTOCType"
#define userdataBookshelfTheme							@"userdataBookshelfTheme"
#define userdataBookmarkFile							@"userdataBookmarkFile"

// user data foe setting
#define userdataOpenDirection							@"udOpenDirection"					// 右から左に開く
#define userdataOpenDirectionValue						YES									// 右から左に開く（右から左）
#define userdataZoomStatus								@"udZoomStatus"						// ページ移動時拡大率維持
#define userdataZoomStatusValue							NO									// ページ移動時拡大率維持（しない）
#define userdataGravityChange							@"udGravityChange"					// 横画面重力自動切り替わり
#define userdataGravityChangeValue						YES									// 横画面重力自動切り替わり（しない）
#define userdataBookShelfType							@"BookShelfType"

#define userdataSpreadChange							@"udSpreadChange"					// 見開きスイッチ
#define userdataSpreadChangeValue						YES									// 見開きスイッチ（しない）

#define userdataCoverSeparate							@"udCoverSeparate"					// 表紙は単独表示
#define userdataCoverSeparateValue						NO									// 表紙は単独表示（しない）

#define userdataCenterShade							@"udCenterShade"					// ページ綴代エフェクト
#define userdataCenterShadeValue					YES									// ページ綴代エフェクト（しない）


#define titleReader										@"titleReader"
#define titleTOC										@"titleTOC"
#define titleSettings									@"titleSettings"
#define titleMPSong										@"titleMPSong"
#define titleMPArtist									@"titleMPArtist"
#define titleMPPlaylist									@"titleMPPlaylist"

#define labelMenu										@"labelMenu"
#define labelRead										@"labelRead"
#define labelViewPhotos									@"labelViewPhotos"
#define labelGetFull									@"labelGetFull"
#define labelCheckNew									@"labelCheckNew"
#define labelGetMore									@"labelGetMore"
#define labelRecommended								@"labelRecommended"

#define labelMainMenu									@"labelMainMenu"

#define labelOK											@"labelOK"
#define labelCancel										@"labelCancel"
#define labelBack										@"labelBack"

#define labelSettingsPage								@"labelSettingsPage"
#define labelSettingsPageRemember						@"labelSettingsPageRemember"
#define labelSettingsPageRememberTop					@"labelSettingsPageRememberTop"
#define labelSettingsPageRememberContinue				@"labelSettingsPageRememberContinue"
#define labelSettingsPageAnimation						@"labelSettingsPageAnimation"
#define labelSettingsPageAnimationNone					@"labelSettingsPageAnimationNone"
#define labelSettingsPageAnimationScroll				@"labelSettingsPageAnimationScroll"
#define labelSettingsImageScale							@"labelSettingsImageScale"
#define labelSettingsImageScaleAspectFit				@"labelSettingsImageScaleAspectFit"
#define labelSettingsImageScaleAspectFill				@"labelSettingsImageScaleAspectFill"
#define labelSettingsTOC								@"labelSettingsTOC"
#define labelSettingsTOCType							@"labelSettingsTOCType"
#define labelSettingsTOCTypeBookshelf					@"labelSettingsTOCTypeBookshelf"
#define labelSettingsTOCTypeList						@"labelSettingsTOCTypeList"
#define labelSettingsBookshelfTheme						@"labelSettingsBookshelfTheme"
#define labelSettingsBookshelfThemeWoodNormal			@"labelSettingsBookshelfThemeWoodNormal"
#define labelSettingsBookshelfThemeWoodBW				@"labelSettingsBookshelfThemeWoodBW"

#define textTopPage										@"textTopPage"
#define textLastPage									@"textLastPage"
#define textBookmarked									@"textBookmarked"
#define textNotBoomarked								@"textNotBoomarked"

#define menuGetFull										@"menuGetFull"
#define menuCheckNew									@"menuCheckNew"
#define menuGetMore										@"menuGetMore"
#define menuSearch										@"menuSearch"
#define menuSearchTitle									@"menuSearchTitle"
#define menuMore										@"menuMore"
#define menuRecommended									@"menuRecommended"
#define menuSmaller										@"menuSmaller"
#define menuLarger										@"menuLarger"
#define menuMusicPlayer									@"menuMusicPlayer"

#define menuIndex										@"menuIndex"
#define menuBookmarkAdd									@"menuBookmarkAdd"
#define menuBookmarkJump								@"menuBookmarkJump"
#define menuSettings									@"menuSettings"

#define keyViewerType									@"Viewer Type"
#define keyPaidType										@"Paid Type"
#define keyUseAdMob										@"Use AdMob"
#define keyPublisherID									@"Publisher-ID"
#define keyCheckNewURL									@"Check New Release URL"
#define keyGetFullURL									@"Get Full Version URL"
#define keyGetMoreURL									@"Get More E-books URL"
#define keyRecommendedURL								@"Recommended For You URL"
#define keyAudioPath									@"AudioPath"
#define keyAudioTitle									@"AudioTitle"
#define keyAudioArtist									@"AudioArtist"

#define urlSearch										@"http://x-search.jp/us/article?media=3&type=2&"

#define filenameTOC										@"epubtoc.data"

#define archiveKeyTOC									@"archiveKeyTOC"

#define fontSizeMin										50
#define fontSizeMax										150

#define musicTitleDefault								@"musicTitleDefault"
#define musicArtistDefault								@"musicArtistDefault"

#define LabelMenuCloseBook								@"menuCloseBook"
#define LabelMenuCloseMenu								@"menuCloseMenu"
#define LabelMenuPageSuffix								@"menuPageSuffix"
#define textAddBookmark									@"textAddBookmark"
#define textDeleteBookmark								@"textDeleteBookmark"
#define LabelTitleBookmark								@"labelTitleBookmark"


#define filenameLock									@"/lock.png"
#define filenameOrientation								@"/orientation.png"
#define filenameClosebutton_metal						@"filenameClosebutton_metal"
#define filenameClosebutton_wood						@"filenameClosebutton_wood"
#define filenameSliderLeft								@"/slider_l.png"
#define filenameSliderRight								@"/slider_r.png"
#define filenameSliderThumb								@"/slider_t.png"
#define filenameMenuCloseButton							@"/barbutton_rr.png"


typedef enum {
	CVMenuIndexRead,
	CVMenuIndexCheckNewOrGetFull,
	CVMenuIndexGetMore,
	CVMenuIndexRecommended,
	CVMenuIndexCount
} CVMenuIndex;

typedef enum {
	CVViewerTypeEpub,
	CVViewerTypeImage
} CVViewerType;

typedef enum {
	CVPaidTypePaid,
	CVPaidTypeFree
} CVPaidType;

typedef enum {
	CVMenuTagCheckNew,
	CVMenuTagGetMore,
	CVMenuTagSearch,
	CVMenuTagSearchTitle,
	CVMenuTagMore,
	CVMenuTagMore2,
	CVMenuTagRecommended,
	CVMenuTagSmaller,
	CVMenuTagLarger,
	CVMenuTagMusicPlayer,
	CVMenuTagMore3,
	CVMenuTagMore4,
	CVMenuTagIndex = 101,
	CVMenuTagBookmarkAdd,
	CVMenuTagBookmarkJump,
	CVMenuTagSettings,
	CVMenuTagLandMain = 201
} CVMenuTag;

typedef enum {
	CVMenuViewCloseBook,
	CVMenuViewSearchSlider,
	CVMenuViewPageLabel,
	CVMenuViewOpenBookmark,
	CVMenuViewSetBookmark,
	CVMenuViewSetOrientation
} CVMenuView;


typedef enum {
	CVMenuSearchModeKeyword,
	CVMenuSearchModeTitle
} CVMenuSearchMode;

typedef enum {
	CVParseModeMeta,
	CVParseModeToc,
	CVParseModeOpf
} CVParseMode;

typedef enum {
	CVTouchableViewTagTop,
	CVTouchableViewTagLeft,
	CVTouchableViewTagRight,
	CVTouchableViewTagBottom
} CVTouchableViewTag;

typedef enum {
	CVSettingsSectionPage,
	CVSettingsSectionTOC,
	CVSettingsSectionCount
} CVSettingsSection;

typedef enum {
	CVSettingsRowPageRemember,
	CVSettingsRowPageAnimation,
	CVSettingsRowImageScale,
	CVSettingsRowPageCount
} CVSettingsRowPage;

typedef enum {
	CVSettingsRowTOCType,
	CVSettingsRowTOCBookshelfTheme,
	CVSettingsRowTOCCount
} CVSettingsRowTOC;

typedef enum {
	CVPageRememberModeContinue,
	CVPageRememberModeTop,
	CVPageRememberModeCount
} CVPageRememberMode;

typedef enum {
	CVPageAnimationModeNone,
	CVPageAnimationModeScroll,
	CVPageAnimationModeCurl,
	CVPageAnimationModeCount
} CVPageAnimationMode;

typedef enum {
	CVImageScaleModeAspectFit,
	CVImageScaleModeAspectFill,
	CVImageScaleModeCount
} CVImageScaleMode;

typedef enum {
	CVTOCTypeBookshelf,
	CVTOCTypeList,
	CVTOCTypeCount
} CVTOCType;

typedef enum {
	CVBookshelfThemeWoodNormal,
	CVBookshelfThemeWoodBW,
	CVBookshelfThemeCount
} CVBookshelfTheme;

typedef enum {
	CVMPTagSong,
	CVMPTagArtist
} CVMPTag;

typedef enum {
	CVMPListTagPlaylist,
	CVMPListTagSelect
} CVMPListTag;
