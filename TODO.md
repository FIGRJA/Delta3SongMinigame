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
    * [X]  прожекторы как показатель жизни
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
    * [ ]  control visible (checkbox in main)
    * [ ]  preview all notes/play-slice //v-slice
    * [X]  lyric preview
    * [ ]  *true* lyric
    * [ ]  custom settings
      * [X]  split OppHitSound
      * [X]  preview characters ?//v-slice
      * [ ]  save as ***other* file/s** (?.neo)
      * [ ]  convert ?
        * [X]  conver from DLLFRE (button)(need remove in featur)
        * [ ]  fullscreen menu
        * [ ]  moveble strums convect
        * [ ]  slice to convector apply
        * [ ]  specical functions for DDLFRE (in preset only used)
        * [ ]  ? custom preset
      * [ ]  scale preview //v-slice
      * [ ]  ? list of lo-fi music
  * [X]  3 players
  * [X]  3 normal icons players
  * [X]  load music from mus
  * [X]  add handler err
  * [X]  lo-fi music FROM v-slice
  * [ ]  custom preview characters //v-slice
  * [ ]  reset all windows
  * [ ]  remember someSettings
  * [ ]  fix visible very long note
  * [X]  fix logOut
* [ ]  genetation
  * [ ]  LLP (midi)
    * [X]  notes
      * [X]  kris short notes
      * [X]  kris long notes
      * [X]  ralsei notes
      * [X]  susie notes
    * [ ]  events
    * [ ]  ? some rofls(spritesMap...)
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
    * [ ]  interesting backGround
    * [ ]  inject resetScore
    * [ ]  inject stars as notes/time
    * [X]  inject song preview

## issuse

* broke censLyric
* susie noteAnimations
* unknow alt-0-Kris
* unknow alt-1-susie
* unknow alt-any-Ralsei
* unknow how load mp3 / jpg
* mobile paths is broken(packs in pl)
* memory leak (not critical)
