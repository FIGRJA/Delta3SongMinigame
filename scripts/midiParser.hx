//package; //dummy deepseak 

import haxe.io.Bytes;
import sys.io.File;

//class MidiParserSimple {
//function onCreate() {//tester
//    trace("h");
//    var mid = File.getBytes("untitled.mid");//my broke patern//FPC not work on my pc
//    trace(mid.length);
//    var xlamidii = parseMidi(mid);
//    for (t in xlamidii.tracks){
//        trace(t.name);
//        for (n in t.notes){
//            trace("c-"+n.channel+" n-"+n.noteNumber+" t-"+n.startTime+" e-"+n.endTime+" o-"+n.velocityOn+" f-"+n.velocityOff);
//        }
//        //for (e in t.tempoEvents){//not used )))
//        //    trace("ti-"+e.time+" te-"+e.tempo);
//        //}
//    }
//}
//  please give me true map of mid

/*
from random song
35 - Long R
36 - short R
------------
38 - short L
39 - Long L
add from FPC pic in GB and ^
28 - RR
30 - RM
32 - RL

35 - KRL
36 - KR
---------
38 - KL
39 - KLL

42 - SR
44 - SM
46 - SL

53 - RAnPoint
54 - RAnCuss
55 - RAnRude
56 - RAnSing
57 - RAnClap
58 - RAnSurprise
59 - RAnShock
60 - RAnPose
61 - RAnBLush
62 - RAnRock3
63 - RAnRock2
64 - RAnRock1

66 - KAnPoint
67 - KAnPose
68 - KAnPlay
69 - KAnPlay
70 - KAnIdle
71 - KAnNoGuitar

72 - SAnPoint
73 - SAnPlay
74 - SAnDrumsticks2
75 - SAnDrumsticks
76 - SAnReady
77 - SAnIdle
*/
setVar("MidiParser",this);
//main
function parseMidi(data:Bytes):Dynamic {
    var result = {
        format: 1,
        timeDivision: 480,
        tracks: []
    };
    
    var pos = 0;
    
    // Читаем заголовок
    var chunkType = readString(data, pos, 4);
    pos += 4;
    if (chunkType != "MThd") throw "Invalid MIDI file";
    
    var headerLength = readInt32(data, pos);
    pos += 4;
    if (headerLength != 6) throw "Invalid header";
    
    result.format = readInt16(data, pos);
    pos += 2;
    var numTracks = readInt16(data, pos);
    pos += 2;
    result.timeDivision = readInt16(data, pos);
    pos += 2;
    
    // Читаем треки
    for (i in 0...numTracks) {
        var track = parseTrack(data, pos);
        result.tracks.push(track.track);
        pos = track.newPos;
    }
    
    return result;
}

function parseTrack(data:Bytes, startPos:Int):Dynamic {
    var track = {
        name: "",
        notes: [],
        tempoEvents: []
    };
    
    var pos = startPos;
    
    var chunkType = readString(data, pos, 4);
    pos += 4;
    if (chunkType != "MTrk") throw "Invalid track";
    
    var trackLength = readInt32(data, pos);
    pos += 4;
    var endPosition = pos + trackLength;
    
    var runningStatus = -1;
    var currentTime = 0;
    
    // Активные ноты
    var activeNotes = [];
    var activeNoteNumbers = [];
    
    while (pos < endPosition) {
        var delta = readVariableLength(data, pos);
        pos = delta.newPos;
        currentTime += delta.value;
        
        var event = data.get(pos);
        pos +=1;
        
        if (event == 0xFF) {
            // Meta event
            var metaType = data.get(pos);
            pos+=1;
            var metaLength = readVariableLength(data, pos);
            pos = metaLength.newPos;
            var metaData = data.sub(pos, metaLength.value);
            pos += metaLength.value;
            
            if (metaType == 0x03) {
                track.name = metaData.toString();
            } else if (metaType == 0x2F) {
                break;
            } else if (metaType == 0x51 && metaLength.value >= 3) {
                var tempo = (metaData.get(0) << 16) | (metaData.get(1) << 8) | metaData.get(2);
                track.tempoEvents.push({
                    time: currentTime,
                    tempo: tempo
                });
            }
        } else if (event == 0xF0 || event == 0xF7) {
            // SysEx event
            var sysexLength = readVariableLength(data, pos);
            pos = sysexLength.newPos;
            pos += sysexLength.value;
        } else {
            // MIDI event
            var status = event;
            var channel = status & 0x0F;
            var command = status >> 4;
            
            if (status < 0x80) {
                runningStatus = status;
                command = status >> 4;
                channel = status & 0x0F;
                status = runningStatus;
            } else {
                runningStatus = status;
            }
            
            switch(command) {
                case 0x08: // Note off
                    var noteNumber = data.get(pos);
                    pos+=1;
                    var velocity = data.get(pos);
                    pos+=1;
                    
                    var noteIndex = findActiveNoteIndex(activeNoteNumbers, noteNumber);
                    if (noteIndex >= 0) {
                        var note = activeNotes[noteIndex];
                        note.endTime = currentTime;
                        note.velocityOff = velocity;
                        track.notes.push(note);
                        
                        activeNotes.splice(noteIndex, 1);
                        activeNoteNumbers.splice(noteIndex, 1);
                    }
                    
                case 0x09: // Note on
                    var noteNumber = data.get(pos);
                    pos+=1;
                    var velocity = data.get(pos);
                    pos+=1;
                    
                    if (velocity == 0) {
                        var noteIndex = findActiveNoteIndex(activeNoteNumbers, noteNumber);
                        if (noteIndex >= 0) {
                            var note = activeNotes[noteIndex];
                            note.endTime = currentTime;
                            note.velocityOff = 0;
                            track.notes.push(note);
                            
                            activeNotes.splice(noteIndex, 1);
                            activeNoteNumbers.splice(noteIndex, 1);
                        }
                    } else {
                        var note = {
                            channel: channel,
                            noteNumber: noteNumber,
                            startTime: currentTime,
                            endTime: 0,
                            velocityOn: velocity,
                            velocityOff: 0
                        };
                        activeNotes.push(note);
                        activeNoteNumbers.push(noteNumber);
                    }
                    
                case 0x0B: // Control change
                    var controller = data.get(pos);
                    pos+=1;
                    var value = data.get(pos);
                    pos+=1;
                    
                    if (controller == 0x7B || controller == 0x7C || controller == 0x7D || 
                        controller == 0x7E || controller == 0x7F) {
                        // All notes off
                        for (note in activeNotes) {
                            note.endTime = currentTime;
                            track.notes.push(note);
                        }
                        activeNotes = [];
                        activeNoteNumbers = [];
                    }
                    
                case 0x0A: // Polyphonic aftertouch
                    pos += 2;
                    
                case 0x0C: // Program change
                    pos += 1;
                    
                case 0x0D: // Channel aftertouch
                    pos += 1;
                    
                case 0x0E: // Pitch bend
                    pos += 2;
                    
                default:
                    // Unknown event
            }
        }
    }
    
    // Завершаем все активные ноты
    for (note in activeNotes) {
        note.endTime = currentTime;
        track.notes.push(note);
    }
    
    return {
        track: track,
        newPos: pos
    };
}

function findActiveNoteIndex(activeNoteNumbers:Array<Int>, noteNumber:Int):Int {
    for (i in 0...activeNoteNumbers.length) {
        if (activeNoteNumbers[i] == noteNumber) {
            return i;
        }
    }
    return -1;
}

function readVariableLength(data:Bytes, startPos:Int):Dynamic {
    var pos = startPos;
    var value = 0;
    var byte = 0;
    
    do {
        byte = data.get(pos);
        pos +=1;
        value = (value << 7) | (byte & 0x7F);
    } while ((byte & 0x80) != 0);
    
    return {
        value: value,
        newPos: pos
    };
}

function readString(data:Bytes, pos:Int, length:Int):String {
    var bytes = data.sub(pos, length);
    return bytes.toString();
}

function readInt32(data:Bytes, pos:Int):Int {
    return (data.get(pos) << 24) | (data.get(pos + 1) << 16) | 
            (data.get(pos + 2) << 8) | data.get(pos + 3);
}

function readInt16(data:Bytes, pos:Int):Int {
    return (data.get(pos) << 8) | data.get(pos + 1);
}
//}
//package;

//class MidiTimeConverter {
    
    /**
     * Конвертирует время в тиках в миллисекунды
     * @param ticks - время в тиках
     * @param timeDivision - тиков на четверть (из MIDI)
     * @param tempoEvents - массив событий темпа
     * @return время в миллисекундах
     */
    function ticksToMilliseconds(ticks:Int, timeDivision:Int, tempoEvents:Array<Dynamic>):Float {
        if (tempoEvents.length == 0) {
            // Если нет событий темпа, используем стандартный темп 120 BPM
            var defaultTempo = 500000; // 120 BPM в микросекундах
            return (ticks / timeDivision) * (defaultTempo / 1000.0);
        }
        
        var currentTime = 0.0;
        var currentTicks = 0;
        var currentTempo = tempoEvents[0].tempo;
        
        for (i in 0...tempoEvents.length) {
            var event = tempoEvents[i];
            var nextTicks = event.time;
            
            // Конвертируем отрезок между событиями
            var ticksDelta = nextTicks - currentTicks;
            if (ticksDelta > 0) {
                var seconds = (ticksDelta / timeDivision) * (currentTempo / 1000000.0);
                currentTime += seconds * 1000; // Переводим в миллисекунды
            }
            
            currentTicks = nextTicks;
            currentTempo = event.tempo;
            
            // Если достигли нужного времени
            if (nextTicks >= ticks) {
                // Добавляем оставшиеся тики
                var remainingTicks = ticks - currentTicks;
                if (remainingTicks > 0) {
                    var seconds = (remainingTicks / timeDivision) * (currentTempo / 1000000.0);
                    currentTime += seconds * 1000;
                }
                return currentTime;
            }
        }
        
        // Если вышли за последнее событие темпа
        var remainingTicks = ticks - currentTicks;
        if (remainingTicks > 0) {
            var seconds = (remainingTicks / timeDivision) * (currentTempo / 1000000.0);
            currentTime += seconds * 1000;
        }
        
        return currentTime;
    }
    
//}