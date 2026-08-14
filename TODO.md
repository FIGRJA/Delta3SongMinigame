* [ ]  PlayState
  * [ ]  дизайн
    * [ ]  splashs
    * [X]  CamNotes
    * [X]  рамка
    * [ ]  свет прожекторов с маской сцены или шейдером
    * [ ]  адекватные цвета
    * [X]  ноты
    * [ ]  начальные 1.5 секунд (начальный счёт)
    * [X]  botplay
  * [ ]  functions
    * [ ]  lyric (переделать)
    * [ ]  прожекторы как показатель жизни
    * [ ]  susie controls (not BotPlay)
    * [ ]  friends
    * [X]  отдельные счетчики combo
    * [ ]  запоздалый счетчик combo у ralsei
    * [ ]  ? занижение сложности
    * [X]  ноты
    * [ ]  реакция на ghost tapping
    * [ ]  ритмичность ralsei
    * [X]  combo system
      * [X]  +10 score
      * [ ]  animate
  * [X]  First logIn
    * [X]  view infinity tutorial
    * [X]  view cpuTapping
    * [X]  practice
    * [X]  view controls
  * [ ]  end Screen
    * [X]  счётчики
    * [ ]  рейтинг
    * [ ]  sounds
    * [X]  ? безраничный слой (относительный центра)
    * [X]  mobile support
  * [ ]  pausing
    * [X]  custom pause
    * [X]  buttons
    * [X]  mobile support
    * [ ]  title song
    * [X]  отчсёт
* [X]  songs Menu
  * [X]  autoDetecting
    * [X]  ERS
    * [X]  NEO
    * [X]  LLP //need conver mp32ogg or metod of load mp3
  * [X]  SongList
  * [X]  Album
  * [ ]  ? multiSL
  * [X]  music Preview
  * [X]  MemoryCheat (use static Array in PlayState as ModchartVarible)
  * [X]  coolScore
  * [X]  mobile support
  * [X]  сортировка
* [ ]  Chart Editor
  * [ ]  customWindow
    * [X]  show It
    * [X]  lyric preview
    * [ ]  *true* lyric
    * [ ]  custom settings
      * [X]  split OppHitSound
      * [X]  preview characters
      * [ ]  save as ***other* file/s** (?.neo)
      * [X]  conver from DLLFRE
  * [X]  3 players
  * [X]  3 normal icons players
  * [X]  load music from mus
  * [X]  add handler err
* [ ]  genetation
  * [ ]  LLP (midi)
    * [X]  notes
      * [X]  kris short notes
      * [X]  kris long notes
      * [X]  ralsei notes
      * [X]  susie notes
    * [ ]  events
  * [X]  ERS (txt)
  * [X]  NEO
  * [X]  GameScript (like haxeScript/Iris)
* [ ]  PsychCovector
  * [ ]  ExtendCE
    * [ ]  functions
    * [X]  self-remove
    * [X]  convert
      * [X]  Psych2stage
      * [ ]  Stage2Psych // ingoring
  * [ ]  events
    * [X]  changeSpeed
    * [X]  changeBPM/PerBPM
    * [ ]  cusomanimations
    * [X]  lyric
  * [X]  notes
    * [X]  convert NoteData
    * [X]  fixLongSize
  * [ ]  ? example mod
    * [X]  GSAF5
    * [ ]  ? port DDLFRE CMMM
* [ ]  PlayerCard as songMenu
  * [ ]  new player
  * [ ]  customCard
    * [X]  inject songList
    * [X]  inject song score
    * [X]  inject albumArt //change selfAlbums
    * [X]  playeble songs
    * [ ]  inject stars as notes/time
    * [X]  inject song preview

## issuse

* broke censLyric
* susie noteAnimations
* unknow alt-0-Kris
* unknow alt-1-susie
* unknow alt-any-Ralsei
* unknow how load mp3
* mobile paths is broken(packs in pl)
