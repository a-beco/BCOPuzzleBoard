BCOPuzzleBoard
==============

パズドラのパズのほうをコピーしたもの。


##使い方
BCOPuzzleBoard.h を import し、以下のようなコードを書くことで画面上の任意の位置に任意のサイズで貼付けられます。

    BCOPuzzleBoard *puzzle = [[BCOPuzzleBoard alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    [puzzle setupBoardWithNumberOfRows:kBCONumberOfRows
                       numberOfColumns:kBCONumberOfColumns];
    [puzzle sizeToFit];
    puzzle.delegate = self;
    [self.view addSubview:puzzle];

-initWithFrame: でインスタンスを生成した後に -setupBoardWithNumberOfRows:numberOfColumns: でインスタンスを初期化します。その際、引数で縦×横に何個の石を配置するかを指定します。

初期化の時点で「ビューの横幅 / numberOfColumnsで指定した値」で石のサイズが決まりますので、frame の width のみを指定しています。初期化後に -sizeToFit を呼べば石に合わせてビューの高さが合うようになっています。

また、delegate で以下の２つのタイミングを通知しています。

**1. ひと固まりの石が消えた後**  
石が消える度に呼ばれ、消えた石の色と数を通知します。

	- (void)puzzleBoard:(BCOPuzzleBoard *)puzzleBoard didEndVanishWithStoneInfo:(BCOVanishedStoneInfo *)stoneInfo;

**2. ターンが終了した後**   
コンボが終了した後に呼ばれます。1回のターンで消した石の総数やコンボ数が取れます。

	- (void)puzzleBoard:(BCOPuzzleBoard *)puzzleBoard didEndTurnWithStoneInfos:(NSArray *)stoneInfos;


ここから敵モンスターへの攻撃などもろもろの処理を行い、終わったらpuzzleBoardの -startNextTurn を呼んで次のターンを開始する想定です。