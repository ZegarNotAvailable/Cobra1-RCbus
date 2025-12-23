# Cobra1

## Założenia wstępne.

Zbudować komputer zgodny z opisanym w czasopiśmie "Audio Video" w połowie lat osiemdziesiątych, wykorzystując istniejące moduły RCbus.
Zaprojektować moduły niezbędne do działania Monitora i Basica - interfejs klawiatury i moduł wideo.

### Do budowy użyłem modułów zaprojektowanych do CA80.
- Backplane,
- CPU,
- Bootloader - przenoszenie oprogramowania z PC za pomocą SD,
- MIK1 - UART 8251A w celu wyświetlania komunikatów monitora Cobry na terminalu (zamiast modułu wideo).

## Pierwszy etap.

Uruchomić monitor Cobra1 z klawiaturą mechaniczną i terminalem zamiast modułu wideo.

- zaprojektowałem moduł interfejsu klawiatury (wykorzystałem projekt klawiatury kolegi @zdzis_ek z Elektrody),
- dodałem program dołączający MIK1 do procedury obsługi ekranu.

![Interfejs klawiatury](https://github.com/ZegarNotAvailable/Cobra1-RCbus/blob/main/HW/Kbd/Klaw-Cobra-RC.png)
![Skoki posrednie](https://github.com/ZegarNotAvailable/Cobra1-RCbus/blob/main/PICT/Cobra-terminal.png)
[![Tytuł Wideo](https://img.youtube.com/vi/cYQcKnM-B-g/0.jpg)](https://youtu.be/cYQcKnM-B-g)

## Drugi etap.

Dodać moduł wideo funkcjonalnie zgodny z pierwowzorem.

## Trzeci etap.

Uzupełnić sprzęt uwzględniając zmiany wprowadzone przez użytkowników:
- kolorowy ekran,
- karta dźwiękowa,
- wymienny generator znaków.
