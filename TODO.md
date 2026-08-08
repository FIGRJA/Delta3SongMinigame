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
    * [ ]  combo system
      * [X]  +10 score
      * [ ]  animate
  * [ ]  First logIn
    * [X]  view infinity tutorial
    * [ ]  view cpuTapping
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
* [ ]  songs Menu
  * [ ]  autoDetecting
    * [X]  ERS
    * [X]  NEO
    * [ ]  LLP
  * [X]  SongList
  * [X]  Album
  * [ ]  ? multiSL
  * [X]  music Preview
  * [X]  MemoryCheat (use static Array in PlayState as ModchartVarible)
  * [ ]  coolScore
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
    * [ ]  notes
      * [X]  kris short notes
      * [ ]  kris long notes
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
  * [ ]  example mod
    * [X]  GSAF5
    * [ ]  ? port DDLFRE CMMM
* [ ]  PlayerCard as songMenu
  * [ ]  new player
  * [ ]  customCard
    * [ ]  inject songList
    * [ ]  inject song score
    * [ ]  inject albumArt
    * [X]  playeble songs
    * [ ]  inject stars as notes/time
    * [ ]  inject song preview

## issuse

* broke censLyric
* susie noteAnimations
* unknow alt-0-Kris
* unknow alt-1-susie
* unknow alt-any-Ralsei
* invisible soundwave when 1 player
* broke firstNote in sections
* unknow how load mp3
