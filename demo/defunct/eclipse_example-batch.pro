instrument = 'CAS_ISS_NA'
times = ['2017-08-21T19:00:00','2017-08-21T20:00:00']
nt = 5



cds = pg_get_cameras(instrument=instrument, time=times)
t_start = bod_time(cds[0])
t_stop = bod_time(cds[1])

t = (dindgen(nt)/(nt-1) * (t_stop - t_start)) + t_start
cd = pg_get_cameras(dd, instrument=instrument, time=t)





pd0 = pg_get_planets(dd, od=cd, name='EARTH')
pd1 = pg_get_planets(dd, od=cd, name='MOON')
pg_reposition, bx=cd, bod_pos(pd0) + (bod_pos(pd1)-bod_pos(pd0))*4, /absolute
pg_repoint, cd=cd, bod_pos(pd0)-bod_pos(cd)


grim, dd, cd=cd, order=0, xsize=768, ysize=768, /activate, plt_distmax=const_get('AU'), $
       over=['center', $
             'terminator:MOON', $
             'shadow:MOON', $
             'limb:EARTH,MOON', $
             'planet_grid:EARTH,MOON'], frame='limb';, /render_auto
