# Ethernet

Данный репозиторий будет содержать ядра для Ethernet, до написания которых у меня дошли руки.

## 64b/66b 

### Кодер

#### Порты модуля ***coder_64b66b***: 
+ Глобальные
    + **clk** - *Input* - тактовая частота,
    + **reset_n** - *Input* - асинхронный сброс,

+ Входной поток
    + **s_axis_ttype** - *Input* - 2-битный тип входного слова (control или data)
    + **s_axis_tdata** - *Input* - 64-битное слово данных 
    + **s_axis_tvalid** - *Input* - 1-битный сигнал валидности входных данных
    + **s_axis_tready** - *Output* - 1-битный сигнал готовности к приему данных

+ Выходной поток
    + **m_axis_tdata** - *Output* - 66-битное слово скремблированных данных
    + **m_axis_tvalid** - *Output* - 1-битный сигнал валидности выходных данных
    + **m_axis_tready** - *Input* - 1-битный сигнал готовности приемного модуля 


### Декодер