//Dew_condensation.pde
//結露
//2016/07/20 
//1-3-48 ReinaNozaki

////////////////////////////////////////////////////////////////////////////
////////  結露を拭って絵を描くことができるようになっています        ////////
////////  左右キーまたはメニューのボタンで指、息、手のモードに変更  ////////
////////  上下キーまたはバーをクリックでメニュー開閉                ////////
////////  cキーで画面クリアができます。                             ////////
////////  更に、手のモードの時にマウスをクリックしたまま            ////////
////////  おいておくと手の周りに結露が現れます。                    ////////
////////////////////////////////////////////////////////////////////////////

//結露が窓に現れている様子を背景画像の上に半透明の四角を敷き詰める事で表現しました。

//minimライブラリを使用しました。
//背景BGMと雨の効果音をループで流し続けています。
import ddf.minim.*;
Minim tuki;
AudioPlayer player1;
Minim ame;
AudioPlayer player2;

PImage haikei;
PImage te;
PImage button;
PImage credit;
PImage load;

int nx = 256;  //横の数
int ny = 200;  //縦の数
int m = 3;  //一辺の大きさ
int sa = 100;  //上下左右の画面外に置いておく分の配列の量
int mode = 0;
int [][] swi = new int [nx+sa][ny+sa];
float [][] kosa = new float [nx+sa][ny+sa];
//手のひらを表示されるための配列
String [][] pix;

void setup() {
  surface.setSize(nx*m, ny*m+5);
  noCursor();
  textAlign(CENTER);
  //画像、音楽
  tuki = new Minim(this);
  player1 = tuki.loadFile("月の記憶.mp3");
  ame = new Minim(this);
  player2 = ame.loadFile("kan_ge_ame03.mp3");
  player1.loop();
  player2.loop();

  haikei = loadImage("haikei.png");
  te = loadImage("te.png");
  button = loadImage("button.png");
  credit = loadImage("クレジット2.png");
  load = loadImage("load.png");
  //配列の初期化：透明度、垂れる加速度、加速度の増加量
  for (int i = 0; i <nx+sa; i++) {
    for (int j = 0; j<ny+sa; j++) {
      kosa[i][j] = 150;
      t[i][j] = 0;
      cnt[i][j] = 0;
    }
  }
  dot_te();
}

int count = 0;
void draw() {  
  //tint(170, 190, 210);
  tint(-1);
  image(haikei, 0, 0, width, height-5);
  tareru();
  kosahenkou();
  sotowaku();
  drawmenu();
  mode();
  //ロゴマークを描く
  if (count < 300) {
    tint(-1);
    if (count > 18) tint(-1, 255*(255-(count-15)*20)/255);
    image(load, 0, 0, width, height);
  }
  count++;
}

int f = 0; //メニューを開くかとじるか
void keyPressed() {
  if (keyCode == RIGHT) {
    mode++;
    if (mode > 2) mode = 0;
  }
  if (keyCode == LEFT) {
    mode--;
    if (mode < 0) mode = 2;
  }
  if (keyCode == UP) f = 1;
  if (keyCode == DOWN) f = 2;
  if (key == 'c') {
    for (int i = 0; i <nx+sa; i++) {
      for (int j = 0; j<ny+sa; j++) {
        swi[i][j] = 0;
        t[i][j] = 0;
        cnt[i][j] = 0;
      }
    }
  }
}

//メニューが閉じているときにバーを押すとメニューが開き、
//メニューが開いているときにボタンを押すと
//モードを切り替えることができる
int cre = 0;
void mousePressed() {
  cre = 0; //どこでもいいから押すとクレジットが閉じる
  if (b == 1) {
    for (int i = 0; i < 3; i++) { //ボタンの判定
      if (mouseY > height-130 && mouseY < height-30 && mouseX > 50+i*150 && mouseX < 150+i*150)  mode = i;
    }
    //バーを押すとメニューが閉じる
    if (mouseY > height-230 && mouseY < height-170) f = 0;
    //クレジットを開く
    if (mouseX>width-210 && mouseX < width-110 && mouseY>height-140 && mouseY<height-100 && cre == 0) cre = 1;
  }else{
    if (mouseY > height-60) f = 1; //バーを押すとメニューが開く
  }
}

void mouseReleased() {
  time = 0;
}

//指で結露を拭って描くときの判定の関数です。
//マウスポインタ周辺だけループさせるようにしています。
void yubidekaku(int x, int y) {
  for (int i = x-7; i <= x+7; i++) {
    for (int j = y-7; j <= y+7; j++) {
      float kyori = sqrt((x-i)*(x-i)+(y-j)*(y-j));
      if (kyori < 5 && swi[i][j] != 2 && swi[i][j] != 3) swi[i][j] = 1;
      if (kyori < 4 && swi[i][j] != 3) swi[i][j] = 2;
      if (kyori < 3) swi[i][j] = 3;
    }
  }
}

//息を吹きかけたときの判定の関数です。
//マウスの位置から+-15升の分だけ繰り返させることによって
//少しでも動作を軽くしています。
//マウスのポインタからの距離が15以下なら切り替え変数を4に、11以下なら5にという変え方をしています。
void ikiwokakeru(int x, int y) {
  for (int i = x-15; i <= x+15; i++) {
    for (int j = y-15; j <= y+15; j++) {
      float kyori = sqrt((x-i)*(x-i)+(y-j)*(y-j));
      if (kyori < 15 && swi[i][j] != 5 && swi[i][j] != 6 && swi[i][j] != 7) swi[i][j] = 4;
      if (kyori < 10 && swi[i][j] != 6 && swi[i][j] != 7) swi[i][j] = 5;
      if (kyori < 5 && swi[i][j] != 7) swi[i][j] = 6;
      if (kyori < 2) swi[i][j] = 7;
    }
  }
}

//手のひらの形にを描写する関数です。
//0,1のテキスト化した画像データを配列に組み込んで、
//1ならその部分の切り替え変数を指定したものに変更するという仕組みに
//しているので、どのモードにも変更出来るようになっています。
void drawte(int x, int y, int m) {
  for (int i = 0; i < 37; i++) {
    for (int j = 0; j < 31; j++) {
      int n = Integer.parseInt(pix[i][j]);
      if ( n == 1 ) swi[x+j][y+i] = m;
    }
  }
}

//手の平を同じところに置いておくとその熱で周りに
//結露が現れる現象を表すとき、手が同じところに
//置かれ続けていたかを判定するための関数です。
//ポインタの座標の変化量が１以下のときカウントを増やし、
//動いたらリセットするルールで、一定以上カウントが増えたら
//手のひらで描写する関数を利用して、手のひらの上下左右１マスずつ
//徐々に結露ができる状態の判定に変えるようにしています。
int time = 0;
void tenoatohantei() {
  if (abs(pmouseX - mouseX) < 1 && abs(pmouseY - mouseY) < 1) time++;
  else time = 0;
  if (time >= 30) {
    for (int i = -1; i <= 1; i++ ) {
      for (int j = -1; j <= 1; j++) {
        drawte(mouseX / m + sa/2-16+i, mouseY / m + sa/2-19+j, 5);
      }
    }
  }
}

// それぞれのマスについて、濃さが薄いモードのマスでかつ
//その下のマスがその次に濃いモードだった升のみ
//80000/フレームの確率でそこから水滴が垂れるようにモードを変える関数です。
void tareru() {
  int rnd_num;
  for (int i = sa/2; i <= nx+sa/2; i++) {
    for (int j = sa/2; j <= ny+sa/2; j++) {
      rnd_num = (int)random(70000);
      if (kosa[i][j+1] >= 60 && kosa[i][j] <=30) {
        if (rnd_num == 20) swi[i][j] = 20;
      }
    }
  }
}

//水滴をたらす垂らす関数です。
//切り替え変数が20のマスの一つ下のマスの透明度の切り替え変数を一番薄くなるものに変えて、
//ｙ軸の色を変える幅をtと置いて別の関数内で変化させることによって
//水滴垂れる速度を加速できるようにしました。
//更に一番下までたれたら加速度や判定をリセットすることで
//また同じところから水滴が垂れることができるようにもしています。
void tarasu(int i, int j, float d) {
  if (j + d <= ny+sa/2+10) {
    for (int u = j; u <= j+d; u++) {
      swi[i-1][u+1] = 3;
      swi[i][u+1] = 3;
      swi[i+1][u+1] = 3;
    }
  } else {
    cnt[i][j] = 0;
    t[i][j] = 0;
  }
}

//モード切り替えの変数です。
//変数の値に応じて指、息、手に変わるようにしています。
//また、メニューが開いているときメニューの裏には反応しない、
//メニューの上の部分に描写しっようとするとメニューが閉じる
//などの設定もしています。
void mode() {
  if (mode == 0) {
    fill(-1, 150);
    noStroke();
    ellipse(mouseX, mouseY, 14, 14);
    if (mousePressed && (b == 0 || b == 1 && mouseY < height - 230)) {
      yubidekaku(mouseX / m + sa/2, mouseY / m + sa/2);
      if (b == 1) f = 0;
    }
  } else if (mode == 1) {
    stroke(-1, 150);
    strokeWeight(3);
    noFill();
    ellipse(mouseX, mouseY, 30, 30);
    if (mousePressed && (b == 0 || b == 1 && mouseY < height - 230)) {
      ikiwokakeru(mouseX / m + sa/2, mouseY / m + sa/2);
      if (b == 1) f = 0;
    }
  } else if (mode == 2) {
    tint(-1, 180);
    image(te, mouseX-16*m, mouseY-19*m);
    if (mousePressed && (b == 0 || b == 1 && mouseY < height - 230)) {
      tenoatohantei();
      drawte(mouseX / m + sa/2-16, mouseY / m + sa/2-19, 3);
      if (b == 1) f = 0;
    }
  }
}

float [][] t = new float [nx+sa][ny+sa];
float [][] cnt = new float [nx+sa][ny+sa];

//透明度関数を増減させる関数です。
//切り替え変数が４なら60まで1/フレームずつ増加、5なら…と言うように変えています。
void kosahenkou() {
  for (int i = sa/2; i <= nx+sa/2; i++) {
    for (int j = sa/2; j <= ny+sa/2; j++) {
      switch(swi[i][j]) {
      case 0:
        kosa[i][j] = 150;
        break ;
      case 1:  //デクリメント弱
        kosa[i][j]-= 1;
        if (kosa[i][j] <100) kosa[i][j] = 100;
        break;
      case 2:  //デクリメント中
        kosa[i][j]-= 10;
        if (kosa[i][j] <60) kosa[i][j] = 60;
        break;
      case 3:  //デクリメント強
        kosa[i][j]-= 30;
        if (kosa[i][j] <30) kosa[i][j] = 30;
        break;
      case 4:  //インクリメント弱
        kosa[i][j]+= 1;
        if (kosa[i][j] >60) kosa[i][j] -= 1;
        break;
      case 5:  //インクリメント中の下
        kosa[i][j]+= 10;
        if (kosa[i][j] > 100) kosa[i][j] -= 10;
        break;
      case 6:  //インクリメント中の上
        kosa[i][j]+= 15;
        if (kosa[i][j] > 130) kosa[i][j] -= 15;
        break;
      case 7:  //インクリメント強
        kosa[i][j]+= 20;
        if (kosa[i][j] > 140) kosa[i][j] = 140;
        break;
        //水滴を垂らす判定の関数です。
        //t配列が垂れる加速度でcnt分だけ早くなるようにしています。
      case 20:
        t[i][j] = t[i][j] + 1*cnt[i][j];
        tarasu(i, j, t[i][j]);
        cnt[i][j]++;
        break;
      }
      //半透明の正方形を敷き詰める
      noStroke();
      fill(255, 255, 255, kosa[i][j]);
      rect((i-sa/2)*m, (j-sa/2)*m, m, m);
    }
  }
}

//メニューの描写
void menu(int y, String text) {
  int cnt = 0;
  for (int i = y; i < y+250; i++) {
    int c = 255*cnt/50;
    if (c > 255) c = 255;
    stroke(0, c); 
    strokeWeight(1);
    line(0, i, width, i);
    cnt++;
  }
  fill(-1);
  textSize(20);
  text(text, 170, y+30);
  text("MODE  (Crick button or push ←→ key)", 220, y+80);
  textSize(30);
  text("Credit", width-160, y+120);  
  text("'c' → Reset", width-160, y+180);
  image(button, 50, y+100);
}

int takasa = 60;
int b = 0; //メニューが完全に開いているかどうか
//メニュー表示
void drawmenu() {
  if (f == 1) {
    menu(height-takasa, "Please Push ↓ button to close");
    takasa+=15;
    if (takasa > 230) {
      takasa = 230;
      b = 1;
    }
  } else {
    menu(height-takasa, "Please Push ↑ button to menu");
    takasa -=15;
    b = 0;
    if (takasa < 60) takasa = 60;
  }
  //クレジットを表示させる
  if (cre == 1) {
    tint(-1);
    image(credit, 0, 0, width, height);
  }
}

//textファイルでデータ化した手のひらの画像の情報を
//取り出して、配列の中に入れる関数です。
void dot_te() {
  pix = new String [37][31];
  String line[] = loadStrings("te.txt");
  for (int i = 0; i <line.length; i++) {
    String str = line[i];
    pix[i] = split(str, ',');
  }
}

//窓の外の外枠を描写
void sotowaku() {
  noFill();
  stroke(0);
  strokeWeight(20);
  rect(10, 9, width-20, height+40);
  line(width/2, 0, width/2, height);
  noStroke();
}

//サウンドデータを終了
void stop() {
  player1.close();  
  tuki.stop();
  player2.close();  
  ame.stop();
  super.stop();
}