// for chartEditor Extended

//function onCreate() {
//    addOutText("hi");
//}
function onDance(d) {
    if (d.noteData<3){
        d.animName = d.localnoteData==0?"singLEFT":"singRIGHT";
        d.animName = d.localnoteData==2?"singLEFT-alt":d.animName;
        d.animName = d.noteType!="Alt Animation"?d.animName:(d.localnoteData==0?"singLEFT-alt":"singRIGHT-alt");
        d.animName += d.inSustain?"-hold":"";
    }
    else if (d.noteData<6){
        d.character = getVarH("previewCharaters").members[2];
        d.animName = d.localnoteData==0?"singDOWN":"singUP";
        d.animName = d.localnoteData==2?"clap":d.animName;
        d.animName = d.noteType!="Alt Animation"?d.animName:(d.localnoteData==0?"singLEFT-alt":"singRIGHT-alt");
    }
    else {
        d.character = getVarH("previewCharaters").members[1];
        d.animName = "singLEFT";
        d.animName = d.note.sustainLength>0?d.animName:"idle-alt";
        d.character.animation.play(d.animName+(d.inSustain?"-hold":""), !d.inSustain);
        d.character.idleSuffix = d.note.sustainLength>0?"":"-alt";
        d.character.specialAnim = d.note.sustainLength>0;
        d.canDance = false;

    }
    
}