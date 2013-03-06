//
//  MosaicViewController.m
//  Camera
//
//  Created by 宮尾 研究室 on 11/06/04.
//  Copyright 2011 名古屋大学大学院. All rights reserved.
//

#import "MosaicViewController.h"



@implementation MosaicViewController

@synthesize delegate;
@synthesize myimageView;
@synthesize infoView;

- (void)viewDidLoad {
	[super viewDidLoad];
	twoFinger = NO;

	//範囲枠数の初期化
	rangeFrameNum = 0;
	
	//マルチタッチの可否
	[EditView setMultipleTouchEnabled:YES];
	m_touch1Point = m_touch2Point = CGPointZero;
	
	//ロックの初期化
	effect_lock = UNLOCK;
	stack_lock = UNLOCK;
	
	//カラー選択ボタンの生成
	[self createButton];
	
	//カラー選択ビューを隠す
	[self colorViewHidden:YES];
	
	//サイズ選択ビューを隠す
	[self sizeViewHidden:YES];
	
	//トップビューを表示
	[self topViewHidden:NO];
	
	//ボタン等の角丸および影の追加
	[self roundAndShadow];
	
	// デフォルトの通知センターを取得する
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(touchNOTOK) name:@"SHOW" object:nil];
	[nc addObserver:self selector:@selector(touchOK) name:@"HIDE" object:nil];
    
    cgPointQueue = [[NSMutableArray alloc] init];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [undoStack removeAllObjects];
    previousOrientation = self.interfaceOrientation;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self didRotateFromInterfaceOrientation:UIInterfaceOrientationPortrait];
}

-(IBAction)infoButton{

	
}
-(IBAction)infoViewBackButtonPushed:(UIBarItem *)sender{
	check_flag = NO;
	[infoView removeFromSuperview];
}

-(IBAction)infoViewButtonsPushed:(UIButton *)sender{

	
}

-(void)AuthCheck{

}

//範囲モザイク
-(void)mosaicFill{
	//モザイク範囲を計算
	location = maxXY;
	minXY.x = (minXY.x-biasWidth)*multiWidth;
	minXY.y = (minXY.y-biasHeight)*multiHeight;
	maxXY.x = (maxXY.x-biasWidth)*multiWidth;
	maxXY.y = (maxXY.y-biasHeight)*multiHeight;
	//モザイクをかける
	if(topViewHidden_flag==YES){
		if(effect_lock==UNLOCK){
            @synchronized(self.myimageView){
                self.myimageView.image = [self rangeMosaicImage:myimageView.image];
            }
		}
	}
}
	
-(void)roundAndShadow{
	//角丸半径
	float radius = 10.0;
	
	//サイズビューとカラー選択ビューの角丸
	[[sizeViewBG layer] setCornerRadius:radius];
	[[colorView layer] setCornerRadius:radius];
	[[sizeViewBG layer] setBorderColor:[[UIColor whiteColor] CGColor]];
	[[sizeViewBG layer] setBorderWidth:5.0];
	[[colorView layer] setBorderColor:[[UIColor whiteColor] CGColor]];
	[[colorView layer] setBorderWidth:5.0];
	
	//カメラボタンとアルバムボタンの角丸
	[[cameraButton layer] setCornerRadius:radius];
	[[albumButton layer] setCornerRadius:radius];
	[[cameraButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
	[[cameraButton layer] setBorderWidth:3.0];
	[[albumButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
	[[albumButton layer] setBorderWidth:3.0];
	
	//カメラボタンとアルバムボタンの影
	[[cameraButton layer] setShadowOffset:CGSizeMake(5, 5)];
	[[cameraButton layer] setShadowOpacity:0.3];
	[[albumButton layer] setShadowOffset:CGSizeMake(5, 5)];
	[[albumButton layer] setShadowOpacity:0.3];
	
	radius = 20.0;
	[[maButton layer] setCornerRadius:radius];
	[[rvButton layer] setCornerRadius:radius];
	[[twButton layer] setCornerRadius:radius];
	[[fbButton layer] setCornerRadius:radius];
	[[tmButton layer] setCornerRadius:radius];
	[[maButton layer] setShadowOffset:CGSizeMake(5, 5)];
	[[maButton layer] setShadowOpacity:0.3];
	[[rvButton layer] setShadowOffset:CGSizeMake(5, 5)];
	[[rvButton layer] setShadowOpacity:0.3];
	[[twButton layer] setShadowOffset:CGSizeMake(5, 5)];
	[[twButton layer] setShadowOpacity:0.3];
	[[fbButton layer] setShadowOffset:CGSizeMake(5, 5)];
	[[fbButton layer] setShadowOpacity:0.3];
	[[tmButton layer] setShadowOffset:CGSizeMake(5, 5)];
	[[tmButton layer] setShadowOpacity:0.3];
	
	UIColor *color1 = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
	[[maButton layer] setBorderColor:[color1 CGColor]];
	[[maButton layer] setBorderWidth:3.0];
	[[rvButton layer] setBorderColor:[color1 CGColor]];
	[[rvButton layer] setBorderWidth:3.0];
	[[twButton layer] setBorderColor:[color1 CGColor]];
	[[twButton layer] setBorderWidth:3.0];
	[[fbButton layer] setBorderColor:[color1 CGColor]];
	[[fbButton layer] setBorderWidth:3.0];
	[[tmButton layer] setBorderColor:[color1 CGColor]];
	[[tmButton layer] setBorderWidth:3.0];
}

-(void)touchOK{
	self.view.userInteractionEnabled = YES;
}

-(void)touchNOTOK{
	self.view.userInteractionEnabled = NO;
}

//真理値の否定をとる関数
-(BOOL)reverse:(BOOL)sender{
	if(sender==YES){
		return NO;
	}else{
		return YES;
		}
}
/*************************************************************************************************/
//タッチ処理
/*************************************************************************************************/
//タッチ座標を取得
-(void)getTouches:(UIEvent *)event{
	UITouch	*touch;
	NSEnumerator	*enumerator = [[event allTouches] objectEnumerator];
	touch = [enumerator nextObject];
	m_touch1Point = [touch locationInView:EditView];
	touch = [enumerator nextObject];
	m_touch2Point = [touch locationInView:EditView];
	
	if(m_touch1Point.x < m_touch2Point.x){
		minXY.x = m_touch1Point.x;
		maxXY.x = m_touch2Point.x;
	}else{
		minXY.x = m_touch2Point.x;
		maxXY.x = m_touch1Point.x;
	}
	if(m_touch1Point.y < m_touch2Point.y){
		minXY.y = m_touch1Point.y;
		maxXY.y = m_touch2Point.y;
	}else{
		minXY.y = m_touch2Point.y;
		maxXY.y = m_touch1Point.y;
	}
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	//2本指の場合
	if ([[event allTouches] count]==2) {
		twoFinger = YES;
		
		//タッチ座標を取得
		[self getTouches:event];
		
		//範囲枠を取り除く
		[self deleteRangeFrame];
		
		//範囲枠を表示
		[self createRangeFrame];
	}
	//1本指の場合
	if ([[event allTouches] count]==1) {
		twoFinger = NO;
	}
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	//2本指の場合
	if ([[event allTouches] count]==2) {
		twoFinger = YES;
		
		//タッチ座標を取得
		[self getTouches:event];
		//範囲枠の座標を更新
		[self.view viewWithTag:1113].frame = CGRectMake(minXY.x,minXY.y,maxXY.x-minXY.x,maxXY.y-minXY.y);
	}
	//1本指の場合
	if ([[event allTouches] count]==1) {
		twoFinger = NO;
		
		//タッチ座標を取得
		location = [[touches anyObject] locationInView:self.view];
		//モザイクをかける（１ブロックのみ）
		if([self isTouchingImage]==YES){
            
            [cgPointQueue addObject:[NSValue valueWithCGPoint:location]];
            
			if(effect_lock==UNLOCK){
                @synchronized(self.myimageView){
                    self.myimageView.image = [self mosaicImage:myimageView.image];
                }
			}
		}
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	//二本指の場合
	if ([[event allTouches] count]==2) {
		//タッチ座標を取得
		[self getTouches:event];
		
		//モザイクをかける（範囲指定）
		[self mosaicFill];
		
		//範囲枠を取り除く
		[self deleteRangeFrame];
		
		//undoスタックに現在の画像データをプッシュ
		if(stack_lock == UNLOCK){
			[self performSelectorInBackground:@selector(pushStack) withObject:nil];
		}
		
	}
	//1本指の場合
	if (([[event allTouches] count]==1)&&(twoFinger==NO)) {
		//タッチ座標を取得
		location = [[touches anyObject] locationInView:self.view];
		//モザイクをかける（１ブロックのみ）
		if([self isTouchingImage]==YES){
			if(effect_lock==UNLOCK){
                
                [cgPointQueue addObject:[NSValue valueWithCGPoint:location]];
                
                @synchronized(self.myimageView){
                    self.myimageView.image = [self mosaicImage:self.myimageView.image];
                }

                if(stack_lock == UNLOCK){
                    [self performSelectorInBackground:@selector(pushStack) withObject:nil];
                }
			}
		}
	}
	
	//範囲枠を取り除く
	[self deleteRangeFrame];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	//範囲枠を取り除く
	[self deleteRangeFrame];
}

//範囲枠を生成
-(void)createRangeFrame{
	UILabel *rangeFrame = [[UILabel alloc] initWithFrame:CGRectMake(minXY.x,minXY.y,maxXY.x-minXY.x,maxXY.y-minXY.y)];
	rangeFrame.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
	[[rangeFrame layer] setBorderColor:[[UIColor whiteColor] CGColor]];
	[[rangeFrame layer] setBorderWidth:1.0];
	rangeFrame.tag = 1113;
	[myimageView addSubview:rangeFrame];
	[rangeFrame release];
	rangeFrameNum++;
}

//範囲枠を取り除く
-(void)deleteRangeFrame{
	if(rangeFrameNum >= 1){
		[[self.view viewWithTag:1113] removeFromSuperview];
		rangeFrameNum--;
	}
}

//画像にタッチしているかどうか
-(BOOL)isTouchingImage{
	if(!(((location.y>=246)&&(colorView.hidden==NO))||((location.y>=296)&&(sizeView.hidden==NO)))){
		if(topViewHidden_flag == YES){
			return YES;
		}else{
			return NO;	
		}
	}else{
		return NO;
	}
}

-(void)pushStack{
	//排他的処理
	stack_lock = LOCK;
	
	//自動解放プールを生成
	NSAutoreleasePool* pool;
	pool = [[NSAutoreleasePool alloc]init];
	
	if(mosaic_flag == YES){
		//スタックに画像上データをプッシュ
		NSData *tempImageData;
        tempImageData = [[[NSData alloc] initWithData:UIImagePNGRepresentation(myimageView.image)] autorelease];

		//tempImageData = [[[NSData alloc] initWithData:UIImageJPEGRepresentation(myimageView.image,1.0)] autorelease];
		[undoStack addObject:tempImageData];
		stack_pointer++;
		
		//スタックの上限は30個
		if(stack_pointer>=30){
			[undoStack removeObjectAtIndex:1];
			stack_pointer--;
		}
		mosaic_flag = NO;
	}

	//ロックの解除
	stack_lock = UNLOCK;
 
	//メモリ開放
	[pool release];
}

/*************************************************************************************************/
//トップビュー,カラービュー,サイズビューの表示/非表示
/*************************************************************************************************/
-(void)topViewHidden:(BOOL)sender{
	BOOL notSender=[self reverse:sender];
	
	//ビューの切り替え
	if((sender == YES)&&(topView.hidden == NO)){
		[self.view addSubview:EditView];	
	}
	if((sender == NO)&&(topView.hidden == YES)){
		[EditView removeFromSuperview];	
	}
	
	cameraButton.enabled = notSender;
	albumButton.enabled = notSender;
	cameraButton.hidden = sender;
	albumButton.hidden = sender;
	topView.hidden = sender;
	toolBar.hidden = notSender;
	topViewHidden_flag = sender;
	myimageView.hidden = notSender;
	//カメラのない機種への対応
	if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
		cameraButton.hidden = YES;
		albumButton.center = CGPointMake(160,albumButton.center.y);
	}
}
-(void)colorViewHidden:(BOOL)sender{
	BOOL notSender=[self reverse:sender];
	
	if(sender==NO){//表示するときはアニメーション
		colorView.alpha = 0.0;
		[buttonBack1 setAlpha:0.0];
		[buttonBack2 setAlpha:0.0];
		[self buttonAlfa:0.0];
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		colorView.alpha = 0.5;
		[buttonBack1 setAlpha:0.5];
		[buttonBack2 setAlpha:0.5];
		[self buttonAlfa:1.0];
		[UIView commitAnimations];
		
		//選択中の色を光らせる
		for(NSUInteger i=0;i<COLOR_BUTTON_NUM;i++){
			[[colorButton[i] layer] setBorderWidth:0.0];
		}
		[[colorButton[colorIndex] layer] setBorderColor:[[UIColor whiteColor] CGColor]];	
		[[colorButton[colorIndex] layer] setBorderWidth:3.0];
	}
	[self buttonEnabled:notSender];
	[self buttonHidden:sender];
	colorView.hidden = sender;
	buttonBack1.hidden = sender;
	buttonBack2.hidden = sender;
	
	selectMenuOn = notSender;
}
-(void)sizeViewHidden:(BOOL)sender{
	BOOL notSender=[self reverse:sender];
	
	if(sender==NO){//表示するときはアニメーション
		sizeView.alpha = 0.0;
		sizeViewBG.alpha = 0.0;
		sl.alpha = 0.0;
		memori.alpha = 0.0;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		sizeView.alpha = 1.0;
		sizeViewBG.alpha = 0.5;
		sl.alpha = 1.0;
		memori.alpha = 1.0;
		[UIView commitAnimations];
	}
	sizeView.hidden = sender;
	sizeViewBG.hidden = sender;
	sl.hidden = sender;
	memori.hidden = sender;
	
	selectMenuOn = notSender;
}
-(void)buttonAlfa:(float)sender{
	for(NSUInteger i=0;i<COLOR_BUTTON_NUM;i++){
		colorButton[i].alpha = sender;	
	}
}
-(void)buttonEnabled:(BOOL)sender{
	for(NSUInteger i=0;i<COLOR_BUTTON_NUM;i++){
		colorButton[i].enabled = sender;	
	}
}
-(void)buttonHidden:(BOOL)sender{
	for(NSUInteger i=0;i<COLOR_BUTTON_NUM;i++){
		colorButton[i].hidden = sender;	
	}
}

-(void)createButton{
	int bias = 45;
	
	//ボタンの背景を追加
	int fw = 7; //枠の太さ
    
    CGFloat yShift = 274;
    CGFloat xShift = 20;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        yShift = 114;
        xShift = 80;
    }
        
	buttonBack1 = [[UILabel alloc] initWithFrame:CGRectMake(xShift + 153-fw, (yShift)-fw, bias*2+37+fw*2, bias*2+37+fw*2)];
	buttonBack2 = [[UILabel alloc] initWithFrame:CGRectMake(xShift - fw, (yShift)-fw, bias*2+37+fw*2, bias*2+37+fw*2)];
	buttonBack1.backgroundColor = [UIColor whiteColor];
	buttonBack2.backgroundColor = [UIColor whiteColor];
	[buttonBack1 setAlpha:0.5];
	[buttonBack2 setAlpha:0.5];
	[[buttonBack1 layer] setCornerRadius:10.0];
	[[buttonBack2 layer] setCornerRadius:10.0];
	
	[EditView addSubview:buttonBack1];
	[EditView addSubview:buttonBack2];
	
	for(NSUInteger i=0;i<COLOR_BUTTON_NUM;i++){
		colorButton[i] = [UIButton buttonWithType:UIButtonTypeCustom];
		[colorButton[i] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"CB%02d.bmp",i]] forState:UIControlStateNormal];
        //[colorButton[i] setContentMode:UIViewContentModeBottom];
        [colorButton[i] setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin];
		if(i<MOSAIC1){//不透明
			if(i<3){
				colorButton[i].frame = CGRectMake(xShift + 153+bias*(i%3),yShift,37,37);	
			}else if(i<6){
				colorButton[i].frame = CGRectMake(xShift + 153+bias*(i%3),yShift+bias,37,37);
			}else{
				colorButton[i].frame = CGRectMake(xShift + 153+bias*(i%3),yShift+bias*2,37,37);
			}
		}else{//透明
			if(i<MOSAIC1+3){
				colorButton[i].frame = CGRectMake(xShift + bias*((i-MOSAIC1)%3),yShift,37,37);
			}else if(i<MOSAIC1+6){
				colorButton[i].frame = CGRectMake(xShift + bias*((i-MOSAIC1)%3),yShift+bias,37,37);
			}else{
				colorButton[i].frame = CGRectMake(xShift + bias*((i-MOSAIC1)%3),yShift+bias*2,37,37);
			}
		}
		colorButton[i].tag = i;
		[colorButton[i] addTarget:self action:@selector(selectColor:) forControlEvents:UIControlEventTouchUpInside];
		[colorButton[i] layer].shadowOffset = CGSizeMake(3, 3);
		[colorButton[i] layer].shadowOpacity = 0.8;
		colorButton[i].showsTouchWhenHighlighted = YES;
		
		[EditView addSubview:colorButton[i]];
	}
}
/*************************************************************************************************/
//アクションメソッド
/*************************************************************************************************/
-(IBAction)selectSource:(UIButton *)sender{
	switch(sender.tag){
		case 1://カメラ
			[self startImagePicker:UIImagePickerControllerSourceTypeCamera];
			break;
		case 2://アルバム
			[self startImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
			break;
	}
}

//色選択ボタンが押されたとき
-(IBAction)selectColor:(UIButton *)sender{
	colorIndex = sender.tag;
	
	switch (colorIndex) {
		case WHITE:
			selectR = 255;
			selectG = 255;
			selectB = 255;
			break;
		case BLACK:
			selectR = 0;
			selectG = 0;
			selectB = 0;
			break;
		case RED:
			selectR = 255;
			selectG = 0;
			selectB = 0;
			break;
		case ORANGE:
			selectR = 255;
			selectG = 102;
			selectB = 0;
			break;
		case YELLOW:
			selectR = 255;
			selectG = 255;
			selectB = 0;
			break;
		case GREEN:
			selectR = 102;
			selectG = 255;
			selectB = 0;
			break;
		case CYAN:
			selectR = 0;
			selectG = 255;
			selectB = 219;
			break;	
		case BLUE:
			selectR = 0;
			selectG = 0;
			selectB = 255;
			break;
		case PINK:
			selectR = 255;
			selectG = 153;
			selectB = 255;
			break;
	}
	[self colorViewHidden:YES];
}

//スライダーの値が変化したとき
-(IBAction)changeSlider:(UISlider *)slider{
	if(topViewHidden_flag==NO){
		return;	
	}
	int num;
	double num2;
	
	//四捨五入する
	num2 = slider.value - floor((double)slider.value);
	if(num2<0.5){
		num = floor((double)slider.value);
	}else{
		num = ceil((double)slider.value);
	}
	switch (num) {
		case 1:
			blockSize = imageSize.width/80;
			break;
		case 2:
			blockSize = imageSize.width/60;
			break;
		case 3:
			blockSize = imageSize.width/40;
			break;
		case 4:
			blockSize = imageSize.width/30;
			break;
		case 5:
			blockSize = imageSize.width/20;
			break;
		case 6:
			blockSize = imageSize.width/15;
			break;
		case 7:
			blockSize = imageSize.width/10;
			break;
		case 8:
			blockSize = imageSize.width/7;
			break;
		case 9:
			blockSize = imageSize.width/5;
			break;
	}
	slider.value = num;
}

-(IBAction)done:(id)sender{
    [self saveImage];
    [[self navigationController] popToViewController:(UIViewController *)delegate animated:YES];
}

-(IBAction)cancel:(id)sender{
    [[self navigationController] popViewControllerAnimated:YES];
}

-(IBAction)buttonPushed:(UIButton *)sender{
	if(topViewHidden_flag==NO){
		return;	
	}
    NSLog(@"sender tag: %i", sender.tag);
	switch(sender.tag){
		case 1://color
			if (colorView.hidden == YES) {
				[self colorViewHidden:NO];//カラー選択ビューを表示
				[self sizeViewHidden:YES];//サイズ選択ビューを非表示
			}else{
				[self colorViewHidden:YES];//カラー選択ビューを非表示
			}
			break;
		case 2://size
			if(sizeView.hidden == YES){
				[self sizeViewHidden:NO];  //サイズ選択ビューを表示
				[self colorViewHidden:YES];//カラー選択ビューを非表示
			}else{
				[self sizeViewHidden:YES]; //サイズ選択ビューを非表示
			}
			break;
		case 3://undo
			[self colorViewHidden:YES];    //カラー選択ビューを非表示
			[self sizeViewHidden:YES];     //サイズ選択ビューを非表示
			[self undoEdit];
			break;
    }
}
/*************************************************************************************************/
//アクションシートの生成
/*************************************************************************************************/
-(void)showCameraSheet{
	//カメラのない機種への対応
	if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
		[self startImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
		return;
	}
	//アクションシートを作る
	UIActionSheet * sheet;//(インスタンスの作成)
	
	sheet = [[UIActionSheet alloc]
			 initWithTitle:@""
			 delegate:self
			 cancelButtonTitle:@"Cancel"
			 destructiveButtonTitle:nil
			 otherButtonTitles:@"from Photo Album",@"Camera",nil];
	[sheet autorelease];
	
	//アクションシートを表示する
	actionSheet_flag = AS_CAMERA;
	[sheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    /*
	if(actionSheet_flag==AS_CAMERA){
		//ボタンインデックスをチェックする
		if(buttonIndex >= 2){
			return;	
		}
		
		//ソースタイプを決定する
		UIImagePickerControllerSourceType sourceType = 0;
		switch(buttonIndex){
			case 0:{
				sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
				break;
			}
			case 1:{
				sourceType = UIImagePickerControllerSourceTypeCamera;
				break;
			}
		}
		[self startImagePicker:sourceType];
	}
	if(actionSheet_flag==AS_SHARE){
		if(buttonIndex >= 5){
			return;	
		}
		
		SHKItem *item = [SHKItem image:myimageView.image title:@""];
		
		switch(buttonIndex){
			case 0:{
				[SHKFacebook performSelector:@selector(shareItem:) withObject:item];
				break;
			}
			case 1:{
				[SHKTwitter performSelector:@selector(shareItem:) withObject:item];
				break;
			}
			case 2:{
				[SHKTumblr performSelector:@selector(shareItem:) withObject:item];
				break;
			}
			case 3:{
				[SHKMail performSelector:@selector(shareItem:) withObject:item];
				break;
			}
			case 4:{
				[ai startAnimating];
				UIImageWriteToSavedPhotosAlbum(myimageView.image, self,@selector(finishExport:didFinishSavingWithError:contextInfo:), nil);
				break;
			}	
		}
	}
     */
}
/*************************************************************************************************/
//イメーピッカーコントローラの生成
/*************************************************************************************************/
-(void)startImagePicker:(int)sourceType{
	//使用可能かどうかチェックする(iPod touch等では使用不可)
	
}

-(void)useImage:(UIImage *)image{
    //オリジナル画像を取得する
    NSLog(@"image: %@", image);
	originalImage = [image retain];
    NSLog(@"origional image: %@", originalImage);

	//グラフィックコンテキストを作る
	CGSize size = {0,0};
    
    // image resolution downgrade:
    /*
    if(originalImage.size.width > GC_WIDTH){
        rate = originalImage.size.width/GC_WIDTH;
        size.width = originalImage.size.width/rate;
        size.height =originalImage.size.height/rate;
    
    }else{*/
    
        size.width = originalImage.size.width;
        size.height = originalImage.size.height;
    
    //}

	UIGraphicsBeginImageContext(size);
	
	//画像サイズを保持
	imageSize = size;
	
	//横長
    
    CGFloat w = VWIDTH;
    CGFloat h = VHEIGHT;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        w = VWIDTHLandscape;
        h = VHEIGHTLandscape;
    }
    
    NSLog(@"w: %f h: %f", w, h);
    
    
    if((imageSize.height/imageSize.width)<(h/w)){
		biasWidth = 0;
		biasHeight = (h-(size.height*w/size.width))/2;
		displayWidth = w;
		displayHeight = h-biasHeight*2;
		multiWidth = (float)imageSize.width/displayWidth;
		multiHeight = (float)imageSize.height/displayHeight;
	}else{
		biasWidth = (w-(size.width*h/size.height))/2;
		biasHeight = 0;
		displayWidth = w-biasWidth*2;
		displayHeight = h;
		multiWidth = (float)imageSize.width/displayWidth;
		multiHeight = (float)imageSize.height/displayHeight;
	}
    
    /*
	if((imageSize.height/imageSize.width)<(VHEIGHT/VWIDTH)){
		biasWidth = 0;
		biasHeight = (VHEIGHT-(size.height*VWIDTH/size.width))/2;
		displayWidth = VWIDTH;
		displayHeight = VHEIGHT-biasHeight*2;
		multiWidth = (float)imageSize.width/displayWidth;
		multiHeight = (float)imageSize.height/displayHeight;
	}else{//縦長
		biasWidth = (VWIDTH-(size.width*VHEIGHT/size.height))/2;
		biasHeight = 0;
		displayWidth = VWIDTH-biasWidth*2;
		displayHeight = VHEIGHT;
		multiWidth = (float)imageSize.width/displayWidth;
		multiHeight = (float)imageSize.height/displayHeight;
	}*/
	
	//画像を縮小して、描画する
	CGRect rect;
	rect.origin = CGPointZero;
	rect.size = imageSize;
	[originalImage drawInRect:rect];
	
	//描画した画像を保持
	NSData *tempImageData;
	tempImageData = [[[NSData alloc] initWithData:UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext())] autorelease];
	UIGraphicsEndImageContext();
	
	//保持したデータをスタックに積む
	undoStack = [[NSMutableArray alloc] initWithCapacity:0];
	[undoStack addObject:tempImageData];
	stack_pointer = 0;
	mosaic_flag = NO;
	
	//イメージピッカーを隠す
	//[self dismissModalViewControllerAnimated:YES];
	
	//トップビューを隠す
	[self topViewHidden:YES];
	
	UIImage *newimage = [[[UIImage alloc] initWithData:tempImageData] autorelease];
    
    NSLog(@"newimage: %@", newimage);
	
	//撮影画像の表示
    [self.myimageView setImage:newimage];
	//self.myimageView.image = newimage;
	
	//カラーを指定
	colorIndex = MOSAIC1;
	
	//ブロックサイズ初期化
	sl.value = 5.0;
	blockSize = imageSize.width/20;
    
}

-(void)updateImageSize{
    
}

-(void)imagePickerController:(UIImagePickerController *)picker
	   didFinishPickingImage:(UIImage *)image 
				 editingInfo:(NSDictionary *)editingInfo{
	
	//オリジナル画像を取得する
	originalImage = image;
	
	//グラフィックコンテキストを作る
	CGSize size = {0,0};
	int rate = 0;  //縮小率
	if(picker.sourceType==UIImagePickerControllerSourceTypePhotoLibrary){//アルバムから
		if(originalImage.size.width > GC_WIDTH){
			rate = originalImage.size.width/GC_WIDTH;
			size.width = originalImage.size.width/rate;
			size.height =originalImage.size.height/rate;
		}else{
			size.width = originalImage.size.width;
			size.height =originalImage.size.height;
		}
	}else{//カメラから
		UIImageOrientation orient = originalImage.imageOrientation;
		if((orient == 0)||(orient==1)){
			size.width = GC_HEIGHT;
			size.height= GC_WIDTH;
		}else{
			size.width = GC_WIDTH;
			size.height= GC_HEIGHT;
		}
	}
	UIGraphicsBeginImageContext(size);
	
	//画像サイズを保持
	imageSize = size;
	
	//横長
	if((imageSize.height/imageSize.width)<(VHEIGHT/VWIDTH)){
		biasWidth = 0;
		biasHeight = (VHEIGHT-(size.height*VWIDTH/size.width))/2;
		displayWidth = VWIDTH;
		displayHeight = VHEIGHT-biasHeight*2;
		multiWidth = (float)imageSize.width/displayWidth;
		multiHeight = (float)imageSize.height/displayHeight;
	}else{//縦長
		biasWidth = (VWIDTH-(size.width*VHEIGHT/size.height))/2;
		biasHeight = 0;
		displayWidth = VWIDTH-biasWidth*2;
		displayHeight = VHEIGHT;
		multiWidth = (float)imageSize.width/displayWidth;
		multiHeight = (float)imageSize.height/displayHeight;
	}
	
	//画像を縮小して、描画する
	CGRect rect;
	rect.origin = CGPointZero;
	rect.size = imageSize;
	[originalImage drawInRect:rect];
	
	//描画した画像を保持
	NSData *tempImageData;
	tempImageData = [[[NSData alloc] initWithData:UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext())] autorelease];
	UIGraphicsEndImageContext();
	
	//保持したデータをスタックに積む
	undoStack = [[NSMutableArray alloc] initWithCapacity:0];
	[undoStack addObject:tempImageData];
	stack_pointer = 0;
	mosaic_flag = NO;
	
	//イメージピッカーを隠す
	[self dismissModalViewControllerAnimated:YES];
	
	//トップビューを隠す
	[self topViewHidden:YES];
	
	UIImage *newimage = [[[UIImage alloc] initWithData:tempImageData] autorelease];
	
	//撮影画像の表示
	self.myimageView.image = newimage;
	
	//カラーを指定
	colorIndex = MOSAIC1;
	
	//ブロックサイズ初期化
	sl.value = 5.0;
	blockSize = imageSize.width/20;
	
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	//イメージピッカーを隠す
	[self dismissModalViewControllerAnimated:YES];
}
/*************************************************************************************************/
//画像の編集
/*************************************************************************************************/
-(UIImage *)mosaicImage:(UIImage *)myImage{

	effect_lock = LOCK;
	//画像座標の計算
	
	//CGImageを取得
	CGImageRef cgImage = myImage.CGImage;
	
	//画像情報を取得
	size_t width = CGImageGetWidth(cgImage);
	size_t height = CGImageGetHeight(cgImage);
	size_t bitsPerComponent = CGImageGetBitsPerComponent(cgImage);
	size_t bitsPerPixel = CGImageGetBitsPerPixel(cgImage);
	size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
	CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgImage);
	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(cgImage);
	bool shouldInterpolate = CGImageGetShouldInterpolate(cgImage);
	CGColorRenderingIntent intent = CGImageGetRenderingIntent(cgImage);
	/***********加工中データ用****************/
	//データプロバイダを取得
	CGDataProviderRef dataProvider = CGImageGetDataProvider(cgImage);
    
	//ビットマップデータを取得する
	CFDataRef data = CGDataProviderCopyData(dataProvider);
    
	UInt8 *buffer = (UInt8 *)CFDataGetBytePtr(data);
	/**************************************/
    
    NSArray * cgPointQueueLocal = [[NSArray alloc] initWithArray:cgPointQueue];
    [cgPointQueue removeAllObjects];
    
    for (NSValue * ptVal in cgPointQueueLocal) {
        location = [ptVal CGPointValue];
        
        //モザイクをかけたかどうかのフラグ
        position.x = (location.x-biasWidth)*multiWidth;
        position.y = (location.y-biasHeight)*multiHeight;
        
        if(((0<=position.y)&&(position.y<=imageSize.height))&&((0<=position.x)&&(position.x<=imageSize.width))){
            mosaic_flag = YES;
            
            
            
            
            
            NSUInteger i,j;                          //参照ブロックの左上の座標
            NSUInteger block_i,block_j;              //ブロック内座標インクリメント用
            UInt8 r,g,b;                             //色情報
            UInt8 *tmp;                              //ピクセルポインタ
            int r_average,g_average,b_average;       //ブロック内平均色情報
            
            //タッチしている座標の属するブロックの左上のピクセルを調べる
            i=0;
            j=0;
            while((i<=position.x)&&(i<width)){
                i += blockSize;	
            }
            i -= blockSize;
            while((j<=position.y)&&(j<height)){
                j += blockSize;
            }
            j -= blockSize;
            if((colorIndex==MOSAIC1)||
               (colorIndex==MOSAIC2)||
               (colorIndex==MOSAIC3)||
               (colorIndex==MOSAIC4)||
               (colorIndex==MOSAIC5)||
               (colorIndex==MOSAIC6)||
               (colorIndex==MOSAIC7)||
               (colorIndex==MOSAIC8)||
               (colorIndex==MOSAIC9)){
                //参照しているブロックの中を走査しブロック内輝度平均を求める
                r_average=0;
                g_average=0;
                b_average=0;
                int pixelnum=0;//ピクセル数
                int jend = j+blockSize;
                int iend = i+blockSize;
                if(jend>height){
                    jend = height;
                }
                if(iend>width){
                    iend = width;
                }
                NSUInteger fire;
                for (block_j = j; block_j < jend; block_j++){
                    fire = block_j*bytesPerRow;
                    for(block_i = i; block_i < iend; block_i++){
                        tmp = buffer + fire + block_i*4;
                        r_average += (int)(*(tmp + 0));//r
                        g_average += (int)(*(tmp + 1));//g
                        b_average += (int)(*(tmp + 2));//b
                        pixelnum ++;
                    }
                }
                if(pixelnum!=0){
                    r_average = r_average/(pixelnum) ;
                    g_average = g_average/(pixelnum) ;
                    b_average = b_average/(pixelnum) ;
                }
                
            }
            if(colorIndex == MOSAIC1){//デフォルト
                r = r_average;
                g = g_average;
                b = b_average;
            }else if(colorIndex == MOSAIC2){//白黒
                int ave = r_average*0.2989 + g_average*0.5866 + b_average*0.1144;
                r = ave;
                g = ave;
                b = ave;
            }else if(colorIndex == MOSAIC3){//赤
                r = r_average;
                g = 0;
                b = 0;
            }else if(colorIndex == MOSAIC4){//オレンジ
                r = r_average;
                g = r_average/2.0;
                b = 0;
            }else if(colorIndex == MOSAIC5){//黄色
                r = r_average;
                g = g_average;
                b = 0;
            }else if(colorIndex == MOSAIC6){//緑
                r = 0;
                g = g_average;
                b = 0;
            }else if(colorIndex == MOSAIC7){//水色
                r = 0;
                g = g_average;
                b = b_average;
            }else if(colorIndex == MOSAIC8){//青色
                r = 0;
                g = 0;
                b = b_average;
            }else if(colorIndex == MOSAIC9){//ピンク
                r = r_average;
                g = 0;
                b = b_average;
            }else{
                r = selectR;
                g = selectG;
                b = selectB;
            }
            
            //色情報の代入
            int jend = j+blockSize;
            int iend = i+blockSize;
            
            if(jend>height){
                jend = height;
            }
            if(iend>width){
                iend = width;
            }
            NSUInteger fire2;
            for (block_j = j; block_j < jend; block_j++){
                fire2 = block_j*bytesPerRow;
                for(block_i = i; block_i < iend; block_i++){
                    tmp = buffer + fire2 + block_i*4;
                    *(tmp + 0) = r;
                    *(tmp + 1) = g;
                    *(tmp + 2) = b;
                }
            }
        } // <- if(((0<=position.y)&&(position.y<=imageSize.height))&&((0<=position.x)&&(position.x<=imageSize.width)))
    } // <- for (NSValue * ptVal in cgPointQueue)
    
    [cgPointQueueLocal release];
    
	
	//効果を与えたデータを作成
	CFDataRef effectedData;
	effectedData = CFDataCreate(NULL, buffer, CFDataGetLength(data));
	
	//効果を与えたデータプロバイダを作成
	CGDataProviderRef effectedDataProvider;
	effectedDataProvider = CGDataProviderCreateWithCFData(effectedData);
	
	//効果を与えたデータを画像に変換
	CGImageRef effectedCgImage = CGImageCreate(
											   width,height,
											   bitsPerComponent,bitsPerPixel,bytesPerRow,
											   colorSpace,bitmapInfo,effectedDataProvider,NULL,
											   shouldInterpolate, intent);
	UIImage *effectedImage = [[[UIImage alloc] initWithCGImage:effectedCgImage] autorelease];
	
	//作成したデータを解放
	CGImageRelease(effectedCgImage);
	CFRelease(effectedDataProvider);
	CFRelease(effectedData);
    
    //CFRelease(dataProvider);
    /* test */ //CGDataProviderRelease(dataProvider);
	CFRelease(data);
    
    effect_lock = UNLOCK;
    
    return effectedImage;
}

-(UIImage*)differenceBetween:(UIImage *)image1 and:(UIImage *)image2 {
	effect_lock = LOCK;
	//モザイクをかけたかどうかのフラグ
	if(((0<=minXY.y)||(maxXY.y<=imageSize.height))&&((0<=minXY.x)||(maxXY.x<=imageSize.width))){
		mosaic_flag = YES;	
	}else{
		effect_lock = UNLOCK;
		return image1;
	}
	
	//CGImageを取得
    CGImageRef initial = image2.CGImage;
	CGImageRef cgImage = image1.CGImage;
	
	//画像情報を取得
	size_t width = CGImageGetWidth(cgImage);
	size_t height = CGImageGetHeight(cgImage);
	size_t bitsPerComponent = CGImageGetBitsPerComponent(cgImage);
	size_t bitsPerPixel = CGImageGetBitsPerPixel(cgImage);
	size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
	CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgImage);
    
    
	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(cgImage);
	bool shouldInterpolate = CGImageGetShouldInterpolate(cgImage);
	CGColorRenderingIntent intent = CGImageGetRenderingIntent(cgImage);
    
    
	/***********加工中データ用****************/
	//データプロバイダを取得
	CGDataProviderRef dataProvider = CGImageGetDataProvider(cgImage);
    CGDataProviderRef dataProvider2 = CGImageGetDataProvider(initial);
	//ビットマップデータを取得する
	CFDataRef data = CGDataProviderCopyData(dataProvider);
    CFDataRef data2 = CGDataProviderCopyData(dataProvider2);

	UInt8 *buffer = (UInt8 *)CFDataGetBytePtr(data);
    UInt8 *buffer2 = (UInt8 *)CFDataGetBytePtr(data2);

	/**************************************/
	
	NSUInteger i,j;                          //参照ブロックの左上の座標
	UInt8 *tmp;                              //ピクセルポインタ
    UInt8 *tmp2;
	
	//**************************************loop*****************************************
    NSUInteger fire2;

    int matches = 0;
    int total = 0;
	for(j = 0;j<height;j++){
        fire2 = j*bytesPerRow;
		for(i = 0;i<width;i++){		
            tmp = buffer + fire2 + i*4;
            tmp2 = buffer2 + fire2 + i*4;
            
            BOOL rEqual = (*(tmp + 0) == *(tmp2 + 0));
            BOOL gEqual = (*(tmp + 1) == *(tmp2 + 1));
            BOOL bEqual = (*(tmp + 2) == *(tmp2 + 2));
            
            if (rEqual && gEqual && bEqual) {
                *(tmp + 0) = 0; // red
                *(tmp + 1) = 0; // green
                *(tmp + 2) = 0; // blue
                *(tmp + 3) = 0; // alpha
                matches++;
            }
            total++;
            
		}
	}
	//**************************************loop*****************************************
	
	//効果を与えたデータを作成
	CFDataRef effectedData;
	effectedData = CFDataCreate(NULL, buffer, CFDataGetLength(data));
	
	//効果を与えたデータプロバイダを作成
	CGDataProviderRef effectedDataProvider;
	effectedDataProvider = CGDataProviderCreateWithCFData(effectedData);
	
	//効果を与えたデータを画像に変換
	CGImageRef effectedCgImage = CGImageCreate(
											   width,height,
											   bitsPerComponent,bitsPerPixel,bytesPerRow,
											   colorSpace,bitmapInfo,effectedDataProvider,NULL,
											   shouldInterpolate, intent);
	UIImage *effectedImage = [[[UIImage alloc] initWithCGImage:effectedCgImage] autorelease];
    
	//作成したデータを解放
	CGImageRelease(effectedCgImage);
	CFRelease(effectedDataProvider);
	CFRelease(effectedData);
	CFRelease(data);
    CFRelease(data2);
	
	effect_lock = UNLOCK;
	return effectedImage;
}

-(UIImage*)rangeMosaicImage:(UIImage *)myImage{
	effect_lock = LOCK;
	//モザイクをかけたかどうかのフラグ
	if(((0<=minXY.y)||(maxXY.y<=imageSize.height))&&((0<=minXY.x)||(maxXY.x<=imageSize.width))){
		mosaic_flag = YES;	
	}else{
		effect_lock = UNLOCK;
		return myImage;
	}
	
	//CGImageを取得
	CGImageRef cgImage = myImage.CGImage;
	
	//画像情報を取得
	size_t width = CGImageGetWidth(cgImage);
	size_t height = CGImageGetHeight(cgImage);
	size_t bitsPerComponent = CGImageGetBitsPerComponent(cgImage);
	size_t bitsPerPixel = CGImageGetBitsPerPixel(cgImage);
	size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
	CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgImage);
	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(cgImage);
	bool shouldInterpolate = CGImageGetShouldInterpolate(cgImage);
	CGColorRenderingIntent intent = CGImageGetRenderingIntent(cgImage);
	/***********加工中データ用****************/
	//データプロバイダを取得
	CGDataProviderRef dataProvider = CGImageGetDataProvider(cgImage);
	//ビットマップデータを取得する
	CFDataRef data = CGDataProviderCopyData(dataProvider);
	UInt8 *buffer = (UInt8 *)CFDataGetBytePtr(data);
	/**************************************/
	
	NSUInteger i,j;                          //参照ブロックの左上の座標
	NSUInteger block_i,block_j;              //ブロック内座標インクリメント用
	UInt8 r,g,b;                             //色情報
	UInt8 *tmp;                              //ピクセルポインタ
	int r_average,g_average,b_average;       //ブロック内平均色情報
	
	//**************************************loop*****************************************
	for(j = minXY.y;j<maxXY.y;j=j+blockSize){
		for(i = minXY.x;i<maxXY.x;i=i+blockSize){		
			
			//ブロック色の計算
			if((colorIndex==MOSAIC1)||
			   (colorIndex==MOSAIC2)||
			   (colorIndex==MOSAIC3)||
			   (colorIndex==MOSAIC4)||
			   (colorIndex==MOSAIC5)||
			   (colorIndex==MOSAIC6)||
			   (colorIndex==MOSAIC7)||
			   (colorIndex==MOSAIC8)||
			   (colorIndex==MOSAIC9)){
				//参照しているブロックの中を走査しブロック内輝度平均を求める
				r_average=0;
				g_average=0;
				b_average=0;
				int pixelnum=0;//ピクセル数
				int jend = j + blockSize;
				int iend = i + blockSize;
				
				if(jend>maxXY.y){
					jend = maxXY.y;
				}
				if(iend>maxXY.x){
					iend = maxXY.x;
				}
				if(jend>height){
					jend = height;
				}
				if(iend>width){
					iend = width;
				}
				NSUInteger fire;
				for (block_j = j; block_j < jend; block_j++){
					fire = block_j*bytesPerRow;
					for(block_i = i; block_i < iend; block_i++){
						tmp = buffer + fire + block_i*4;
						r_average += (int)(*(tmp + 0));//r
						g_average += (int)(*(tmp + 1));//g
						b_average += (int)(*(tmp + 2));//b
						pixelnum ++;
					}
				}
				if(pixelnum!=0){
					r_average = r_average/(pixelnum) ;
					g_average = g_average/(pixelnum) ;
					b_average = b_average/(pixelnum) ;
				}
				
			}
			if(colorIndex == MOSAIC1){//デフォルト
				r = r_average;
				g = g_average;
				b = b_average;
			}else if(colorIndex == MOSAIC2){//白黒
				int ave = r_average*0.2989 + g_average*0.5866 + b_average*0.1144;
				r = ave;
				g = ave;
				b = ave;
			}else if(colorIndex == MOSAIC3){//赤
				r = r_average;
				g = 0;
				b = 0;
			}else if(colorIndex == MOSAIC4){//オレンジ
				r = r_average;
				g = r_average/2.0;
				b = 0;
			}else if(colorIndex == MOSAIC5){//黄色
				r = r_average;
				g = g_average;
				b = 0;
			}else if(colorIndex == MOSAIC6){//緑
				r = 0;
				g = g_average;
				b = 0;
			}else if(colorIndex == MOSAIC7){//水色
				r = 0;
				g = g_average;
				b = b_average;
			}else if(colorIndex == MOSAIC8){//青色
				r = 0;
				g = 0;
				b = b_average;
			}else if(colorIndex == MOSAIC9){//ピンク
				r = r_average;
				g = 0;
				b = b_average;
			}else{
				r = selectR;
				g = selectG;
				b = selectB;
			}
			
			//色情報の代入
			int jend = j + blockSize;
			int iend = i + blockSize;
			
			if(jend>maxXY.y){
				jend = maxXY.y;
			}
			if(iend>maxXY.x){
				iend = maxXY.x;
			}
			if(jend>height){
				jend = height;
			}
			if(iend>width){
				iend = width;
			}
			
			NSUInteger fire2;
			for (block_j = j; block_j < jend; block_j++){
				fire2 = block_j*bytesPerRow;
				for(block_i = i; block_i < iend; block_i++){
					tmp = buffer + fire2 + block_i*4;
					*(tmp + 0) = r;//r
					*(tmp + 1) = g;//g
					*(tmp + 2) = b;//b
				}
			}
		}
	}
	//**************************************loop*****************************************
	
	//効果を与えたデータを作成
	CFDataRef effectedData;
	effectedData = CFDataCreate(NULL, buffer, CFDataGetLength(data));
	
	//効果を与えたデータプロバイダを作成
	CGDataProviderRef effectedDataProvider;
	effectedDataProvider = CGDataProviderCreateWithCFData(effectedData);
	
	//効果を与えたデータを画像に変換
	CGImageRef effectedCgImage = CGImageCreate(
											   width,height,
											   bitsPerComponent,bitsPerPixel,bytesPerRow,
											   colorSpace,bitmapInfo,effectedDataProvider,NULL,
											   shouldInterpolate, intent);
	UIImage *effectedImage = [[[UIImage alloc] initWithCGImage:effectedCgImage] autorelease];
    	
	//作成したデータを解放
	CGImageRelease(effectedCgImage);
	CFRelease(effectedDataProvider);
	CFRelease(effectedData);
	CFRelease(data);
	
	effect_lock = UNLOCK;
	return effectedImage;
}
/*************************************************************************************************/
//編集の取り消し
/*************************************************************************************************/
-(void)undoEdit{
	if(stack_lock == UNLOCK){
		//呼ばれるたびにアンドゥスタックから画像データをポップして表示
		if([undoStack count]==1){
			NSData *tempImageData = [undoStack objectAtIndex:stack_pointer];
			UIImage *newimage = [[[UIImage alloc] initWithData:tempImageData] autorelease]; 
			self.myimageView.image = newimage;
		}else{
			[undoStack removeLastObject];
			stack_pointer--;
			
			NSData *tempImageData = [undoStack objectAtIndex:stack_pointer];
			UIImage *newimage = [[[UIImage alloc] initWithData:tempImageData] autorelease]; 
			self.myimageView.image = newimage;
		}
	}
}

/*************************************************************************************************/
//画像の保存
/*************************************************************************************************/


//画像をカメラロールに保存
-(void)saveImage{
    NSData * initialImageData = [undoStack objectAtIndex:0];
    UIImage * initialImage = [UIImage imageWithData:initialImageData];
    UIImage * areasChanged = [self differenceBetween:myimageView.image and:initialImage];
    [delegate addMosaicImage:areasChanged];

    //[delegate addMosaicImage:myimageView.image];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField{
	[textField resignFirstResponder];
	return YES;
}

//画像の保存終了時に呼ばれる
-(void)finishExport:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    /*
	[ai stopAnimating];
	if(error){
		UIAlertView *aleatView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"cannot save image" 
														   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
		[aleatView show];
		[aleatView release];
	}else{
		UIAlertView *aleatView = [[UIAlertView alloc] initWithTitle:@"Save Image" message:@"Saved!" 
														   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
		[aleatView show];
		[aleatView release];
	}
	//undoスタックの解放
	[undoStack removeAllObjects];
	[undoStack release];
	
	self.myimageView.image = nil;//myimageViewにセットしたオブジェクトのリリース
	//カラー選択ビューを隠す
	[self colorViewHidden:YES];
	//サイズ選択ビューを隠す
	[self sizeViewHidden:YES];
	//トップビューを表示
	[self topViewHidden:NO];
     */
}

/**************************************************************************************/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (undoStack && [undoStack count] > stack_pointer) {
        NSData *tempImageData = [[undoStack objectAtIndex:stack_pointer] retain];
        [undoStack removeAllObjects];
        [undoStack addObject:tempImageData];
        stack_pointer = 0;
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    [self colorViewHidden:YES];
    return YES;
	//return (toInterfaceOrientation == UIInterfaceOrientationPortrait);	
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    CGSize size = {0,0};
    
    size.width = originalImage.size.width;
    size.height = originalImage.size.height;
    
    CGFloat w = VWIDTH;
    CGFloat h = VHEIGHT;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        w = VWIDTHLandscape;
        h = VHEIGHTLandscape;
        sl.center = CGPointMake(240, 256);
    } else{
        sl.center = CGPointMake(160, 416);
    }
    
    NSLog(@"w: %f h: %f", w, h);
    
    
    if((imageSize.height/imageSize.width)<(h/w)){
		biasWidth = 0;
		biasHeight = (h-(size.height*w/size.width))/2;
		displayWidth = w;
		displayHeight = h-biasHeight*2;
		multiWidth = (float)imageSize.width/displayWidth;
		multiHeight = (float)imageSize.height/displayHeight;
	}else{
		biasWidth = (w-(size.width*h/size.height))/2;
		biasHeight = 0;
		displayWidth = w-biasWidth*2;
		displayHeight = h;
		multiWidth = (float)imageSize.width/displayWidth;
		multiHeight = (float)imageSize.height/displayHeight;
	}
    
    /*
    for (UIView * v in colorItems) {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && UIInterfaceOrientationIsPortrait(fromInterfaceOrientation)) {
            v.center = CGPointMake(v.center.x + 80, v.center.y - 160);
        }
        else if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) {
            v.center = CGPointMake(v.center.x - 80, v.center.y + 160);
        }
    }*/
    
    int bias = 45;
	int fw = 7;
    
    CGFloat yShift = 274;
    CGFloat xShift = 20;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        yShift = 114;
        xShift = 100;
    }
    
	buttonBack1.frame = CGRectMake(xShift + 153-fw, (yShift)-fw, bias*2+37+fw*2, bias*2+37+fw*2);
	buttonBack2.frame = CGRectMake(xShift - fw, (yShift)-fw, bias*2+37+fw*2, bias*2+37+fw*2);
	
	for(NSUInteger i=0;i<COLOR_BUTTON_NUM;i++){
		if(i<MOSAIC1){
			if(i<3){
				colorButton[i].frame = CGRectMake(xShift + 153+bias*(i%3),yShift,37,37);	
			}else if(i<6){
				colorButton[i].frame = CGRectMake(xShift + 153+bias*(i%3),yShift+bias,37,37);
			}else{
				colorButton[i].frame = CGRectMake(xShift + 153+bias*(i%3),yShift+bias*2,37,37);
			}
		}else{
			if(i<MOSAIC1+3){
				colorButton[i].frame = CGRectMake(xShift + bias*((i-MOSAIC1)%3),yShift,37,37);
			}else if(i<MOSAIC1+6){
				colorButton[i].frame = CGRectMake(xShift + bias*((i-MOSAIC1)%3),yShift+bias,37,37);
			}else{
				colorButton[i].frame = CGRectMake(xShift + bias*((i-MOSAIC1)%3),yShift+bias*2,37,37);
			}
		}
	}
}

- (void)dealloc {
    [super dealloc];
    [myimageView release];
	[colorView release];
	[sizeView release];
	[sizeViewBG release];
	[topView release];
	[EditView release];
	[infoView release];
	
	[B1 release];
	[B2 release];
	[B3 release];
	[B4 release];
	[B5 release];
	[cameraButton release];
	[albumButton release];
	
	[thankLabel release];
	[maButton release];
	[rvButton release];
	[twButton release];
	[fbButton release];
	[tmButton release];
	
	for(NSUInteger i=0;i<COLOR_BUTTON_NUM;i++){
		//[colorButton[i] release];	
	}
	[buttonBack1 release];
	[buttonBack2 release];
	
	[toolBar release];
	[sl release];
	[memori release];
	[ai release];
	
}

@end
