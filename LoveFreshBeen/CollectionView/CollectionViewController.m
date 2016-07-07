//
//  CollectionViewController.m
//  LoveFreshBeen
//
//  Created by LeeJay on 16/3/17.
//  Copyright © 2016年 以撒网. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionCategoryModel.h"
#import "LeftTableViewCell.h"
#import "CollectionViewCell.h"
#import "CollectionHeader.h"
#import "LJPlainFlowLayout.h"

@interface CollectionViewController () <UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *collectionDatas;

@end

@implementation CollectionViewController
{
    NSInteger _selectIndex;
    BOOL _isScrollDown;
    CGFloat _lastOffsetY;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _selectIndex = 0;
    _isScrollDown = YES;
    _lastOffsetY = 0;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.collectionView];
    
    NSString *urlStr = @"http://api.liwushuo.com/v2/item_categories/tree";
    [HYBNetworking getWithUrl:urlStr success:^(id response) {
        NSArray *categories = response[@"data"][@"categories"];
        for (NSDictionary *dict in categories) {
            CollectionCategoryModel *model = [CollectionCategoryModel mj_objectWithKeyValues:dict];
            [self.dataSource addObject:model];
            
            NSMutableArray *datas = [NSMutableArray array];
            for (SubCategoryModel *sModel in model.subcategories) {
                [datas addObject:sModel];
            }
            [self.collectionDatas addObject:datas];
        }
        
        [self.tableView reloadData];
        [self.collectionView reloadData];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
        
    } fail:^(NSError *error) {
    
    }];
}

#pragma mark - Getters
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (NSMutableArray *)collectionDatas {
    if (!_collectionDatas) {
        _collectionDatas = [NSMutableArray array];
    }
    return _collectionDatas;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 80, SCREEN_HEIGHT)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.rowHeight = 45;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorColor = [UIColor clearColor];
        [_tableView registerClass:[LeftTableViewCell class] forCellReuseIdentifier:kCellIdentifier_Left];
    }
    return _tableView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        LJPlainFlowLayout *flowlayout = [[LJPlainFlowLayout alloc]init];
        //设置滚动方向
        [flowlayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        //左右间距
        flowlayout.minimumInteritemSpacing = 2;
        //上下间距
        flowlayout.minimumLineSpacing = 2;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(2+80,2+64,SCREEN_WIDTH-80-4,SCREEN_HEIGHT-64-4) collectionViewLayout:flowlayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        //注册cell
        [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier_CollectionView];
        //注册分区头标题
        [self.collectionView registerClass:[CollectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionHeader"];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Left forIndexPath:indexPath];
    CollectionCategoryModel *model = self.dataSource[indexPath.row];
    cell.name.text = model.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectIndex = indexPath.row;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:_selectIndex] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

#pragma mark - CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    CollectionCategoryModel *model = self.dataSource[section];
    return model.subcategories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier_CollectionView forIndexPath:indexPath];
    SubCategoryModel *model = self.collectionDatas[indexPath.section][indexPath.row];
    cell.model = model;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((SCREEN_WIDTH-80-4-4)/3, (SCREEN_WIDTH-80-4-4)/3+30);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier;
    if ([kind isEqualToString: UICollectionElementKindSectionHeader]) {//header
        reuseIdentifier = @"CollectionHeader";
    }
    CollectionHeader *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        CollectionCategoryModel *model = self.dataSource[indexPath.section];
        view.title.text = model.name;
    }
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(SCREEN_WIDTH, 30);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if (!_isScrollDown && collectionView.dragging) {
        [self selectRowAtIndexPath:indexPath.section];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(nonnull UICollectionReusableView *)view forElementOfKind:(nonnull NSString *)elementKind atIndexPath:(nonnull NSIndexPath *)indexPath {
    if (_isScrollDown && collectionView.dragging) {
        [self selectRowAtIndexPath:indexPath.section+1];
    }
}

- (void)selectRowAtIndexPath:(NSInteger)index {
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark - ScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.collectionView == scrollView) {
        _isScrollDown = _lastOffsetY < scrollView.contentOffset.y;
        _lastOffsetY = scrollView.contentOffset.y;
    }
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
