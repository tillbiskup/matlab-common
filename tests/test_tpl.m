% TEST Simple script showing how to work with the template engine TPL and
% for testing purposes.

% (c) 2014, Till Biskup
% 2014-06-20

o = tpl();
o.setTemplate('test_tpl.tpl')
S = struct('foo','dolor','bar','elit','include',true,'really',true,'array',[3 4 5 6 7]);
S.cell = {'a','b','c'};
o.setAssignments(S)
o.render
