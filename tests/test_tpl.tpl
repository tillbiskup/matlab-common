Lorem ipsum {{@foo}} sit amet, consectetur adipiscing {{@bar}}.

{{if include}}
{{if really}}
{{include test2.tpl}}
{{else}}
Gotcha!
{{end}}
{{else}}
Lorem ipsum is boring!
{{end}}

{{@cell(2)}}

{{@array(3)}}

{{for idx = 1:3}}
array({{@idx}}) = {{@array({{@idx}})}}
{{end}}


{{for idx = 1:3}}
{{if really}}
{{for idx2 = 1:3}}
{{@idx2}}: array({{@idx}}) = {{@array({{@idx}})|format=06.2f}}
{{end}}
{{else}}
{{@idx}}
{{end}}
{{end}}

{{if length({{@array}})>1}}
Fantastisch!
{{else}}
Einen Versuch war es wert...
{{end}}

Ein kaskadiertes Feld: {{@cascaded.field}}

Und noch eines: {{@even.more.cascaded.field}}
