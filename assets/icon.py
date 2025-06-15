from math import sin, cos, tan, sqrt, radians
from xml.dom import getDOMImplementation
import argparse

SIZE = 512
OFFSET = SIZE/2
DIT = (SIZE/2)/16.2

def makeElement(doc, tag, **attrs):
  el = doc.createElement(tag)
  for k, v in attrs.items():
    el.setAttribute(k.replace('_', '-'), str(v))
  #el.setAttribute('transform', 'translate({:f}, {:f})'.format(SIZE/2, SIZE/2))
  return el

def pulse(doc, rotation, ir, angle, w, **kwargs):
  start_a = radians(rotation - (angle / 2))
  stop_a = radians(rotation + (angle / 2))
  out_r = ir + w

  pts = [
      (sin(start_a) * ir, -cos(start_a) * ir),
      (sin(start_a) * (ir + w), -cos(start_a) * (ir + w)),
      (sin(stop_a) * (ir + w), -cos(stop_a) * (ir + w)),
      (sin(stop_a) * ir, -cos(stop_a) * ir),
      ]
  
  for i in range(len(pts)):
    x, y = pts[i]
    pts[i] = x+OFFSET, y+OFFSET

  path = [
      'M {:f},{:f}'.format(pts[0][0], pts[0][1]),
      'L {:f},{:f}'.format(pts[1][0], pts[1][1]),
      'A {:f} {:f} 0 0 1 {:f} {:f}'.format(out_r, out_r, pts[2][0], pts[2][1]),
      'L {:f} {:f}'.format(pts[3][0], pts[3][1]),
      'A {:f} {:f} 0 0 0 {:f} {:f}'.format(ir, ir, pts[0][0], pts[0][1]),
  ]
  return makeElement(doc, 'path', d=' '.join(path), **kwargs)

def radial(doc, angle, r, ir=0, **kwargs):
  x1=ir*sin(radians(angle)) + OFFSET
  y1=-ir*cos(radians(angle)) + OFFSET
  x2=r*sin(radians(angle)) + OFFSET
  y2=-r*cos(radians(angle)) + OFFSET
  return makeElement(doc,
                     'line',
                     x1=x1, y1=y1, x2=x2, y2=y2,
                     **kwargs)

def total_dits(l):
  return sum([1 if c == '.' else 3 for c in l]) + len(l) - 1

def letter(doc, parent, l, rotation, angle):
  cur = 3
  for c in reversed(l):
    size = 1 if (c == '.') else 3
    r = pulse(doc, rotation, DIT*cur, angle, DIT*size, fill='#34deeb')
    parent.appendChild(r)
    cur += size + 1

def letters(doc, parent, ls):
  angle = 180.0/len(ls)
  for i, l in enumerate(ls):
    rotation = angle * i * 2
    letter(doc, parent, l, rotation, angle)
    r = (3 + total_dits(l) + 1) * DIT
    r = (5*3+1) * DIT
    parent.appendChild(radial(doc, rotation, r, ir=2*DIT, stroke='black', stroke_width=5, stroke_linecap="round"))

  #parent.appendChild(makeElement(doc, 'circle', cx=OFFSET, cy=OFFSET, r = 2*DIT, fill='black'))

  c = makeElement(doc, 'circle', cx=OFFSET, cy=OFFSET, r = DIT*2, stroke='black', stroke_width=5, fill='none')
  #parent.appendChild(c)
  for i in range(5):
    c = makeElement(doc, 'circle', cx=OFFSET, cy=OFFSET, r = DIT*3*(i+1), stroke='black', stroke_width=5, fill='none')
    parent.appendChild(c)

#svg.appendChild(pulse(doc, 0, 100, 40, 30, fill='#34deeb'))
#svg.appendChild(radial(doc, 20, stroke='orange'))

def main():
  parser = argparse.ArgumentParser(
    prog = 'icon.py',
    description = 'Creates svg icon'
  )
  parser.add_argument('-background', action='store_true')
  args = parser.parse_args()

  impl = getDOMImplementation()
  doc = impl.createDocument(None, None, None)

  svg = doc.createElement('svg')
  svg.setAttribute('xmlns', 'http://www.w3.org/2000/svg')
  svg.setAttribute('xmlns:xlink', 'http://www.w3.org/1999/xlink')
  svg.setAttribute('width', str(SIZE))
  svg.setAttribute('height', str(SIZE))
  svg.setAttribute('viewBox', '{:f} {:f} {:f} {:f}'.format(0, 0, SIZE, SIZE))
  doc.appendChild(svg)

  ls = ['--..', '..-.', '-.-.']
  ls2 = ['-.-', '--...'] + ls
  if args.background:
    svg.appendChild(makeElement(doc, 'rect', x=0, y=0, width=SIZE, height=SIZE, fill='white'))
  letters(doc, svg, ls2)

  with open('assets/cw_icon.svg', 'w') as fp:
    fp.write(doc.toprettyxml())

if __name__ == '__main__':
  main()