dofile(LockOn_Options.common_script_path .. "elements_defs.lua")
dofile(LockOn_Options.script_path .. "materials.lua")

if stringdefs == nil then stringdefs				= {} end


function setSymbolAlignment(symbol, align)
	if align ~= nil then
		symbol.alignment = align
	else
		symbol.alignment = "CenterCenter"
	end
end

function setClipLevel(obj, level)
	level					= level or 0
	obj.h_clip_relation		= h_clip_relations.COMPARE
	obj.level				= DEFAULT_LEVEL + level
end


function setSymbolCommonProperties(symbol, name, pos, parent, controllers, material)
	symbol.name					= name or create_guid_string()
	symbol.isdraw				= true
	symbol.material				= material or default_material
	symbol.additive_alpha		= additive_alpha or false
	symbol.collimated			= collimated or false
	symbol.use_mipfilter		= use_mipfilter

	if parent ~= nil then
		symbol.parent_element = parent
	else 
		symbol.parent_element = default_parent
	end

	if controllers ~= nil then
		if type(controllers) == "table" then
			-- symbol.controllers = controllers
		end
	end
	if default_element_params then  symbol.element_params = default_element_params end
    if default_controllers then symbol.controllers = default_controllers end

	pos							= pos or {0, 0}
	symbol.init_pos				= {pos[1], pos[2], pos[3] or 0}
	
	if z_disabled == true then
		symbol.z_enabled = false
	end

	setClipLevel(symbol)
end

function setStrokeSymbolProperties(symbol)

	if override_materials == true then
		-- Is used for outlined font generated by DMC
		symbol.thickness			= override_thickness
		symbol.fuzziness			= override_fuzziness
    else
		symbol.thickness			= stroke_thickness
		symbol.fuzziness			= stroke_fuzziness
	end

	symbol.draw_as_wire			= dbg_drawStrokesAsWire
	--symbol.use_specular_pass	= false -- ommitted for now as is set for the entire indicator
end

-- NOTE
-- 'pos' is passed as a two-component table - x and y coordinates

local function buildStrokeLineVerts(length, dashed, stroke, gap)
	local verts	= {}
	local inds	= {}

	if dashed == true and stroke ~= nil and gap ~= nil then
		local segLength			= stroke + gap
		local numOfWholePairs	= math.floor(length / segLength)
		local reminder			= length - numOfWholePairs * segLength

		local function addSeg(num)
			local shift1 = num * 2
			verts[shift1 + 1] = {0, num * segLength}
			verts[shift1 + 2] = {0, num * segLength + stroke}

			inds[shift1 + 1] = shift1
			inds[shift1 + 2] = shift1 + 1
		end

		for segNum = 0, numOfWholePairs - 1 do
			addSeg(segNum)
		end

		if reminder > 0 then
			if reminder >= stroke then
				addSeg(numOfWholePairs)
			else
				local shift1 = numOfWholePairs * 2
				verts[shift1 + 1] = {0, numOfWholePairs * segLength}
				verts[shift1 + 2] = {0, numOfWholePairs * segLength + reminder}

				inds[shift1 + 1] = shift1
				inds[shift1 + 2] = shift1 + 1
			end
		end
	else
		verts	= {{0, 0}, {0, length}}
		inds	= {0, 1}
	end

	return verts, inds
end

function setPlaceholderCommonProperties(placeholder, name, pos, parent, controllers)
	placeholder.name			= name or create_guid_string()
	pos							= pos or {0, 0}
	placeholder.init_pos		= {pos[1], pos[2], 0}
	placeholder.collimated		= collimated or false

	if parent ~= nil then
		placeholder.parent_element	= parent
	else
		placeholder.parent_element	= default_parent
	end

	if controllers ~= nil then
		-- placeholder.controllers		= controllers
	end
end

function addPlaceholder(name, pos, parent, controllers)
	local placeholder			= CreateElement "ceSimple"
	setPlaceholderCommonProperties(placeholder, name, pos, parent, controllers)

	Add(placeholder)
	return placeholder
end


-- Stroke text with glyphs described in a .svg file
function addStrokeText(name, value, stringdef, align, pos, parent, controllers, formats, font)
	local txt = CreateElement "ceStringSLine"
    font = font or stroke_font
    setSymbolCommonProperties(txt, name, pos, parent, controllers, font)
	setSymbolAlignment(txt, align)
	txt.reverse_video = true
	-- custom size is noted in documents as in percents from the original one
	if type(stringdef) == "table" then
		txt.stringdefs = stringdef
	else
		txt.stringdefs = stringdefs[stringdef]
	end

	if value ~= nil then
		txt.value = value
	end

	txt.formats		= formats

	Add(txt)
	return txt
end


function addText(name, value, stringdef, align, pos, parent, controllers, formats, font)
	local txt = CreateElement "ceStringPoly"
	setSymbolCommonProperties(txt, name, pos, parent, controllers, font or stroke_font)
	setSymbolAlignment(txt, align)

	-- custom size is noted in documents as in percents from the original one
	if type(stringdef) == "table" then
		txt.stringdefs = stringdef
	else
		txt.stringdefs = stringdefs[stringdef]
	end

	if value ~= nil then
		txt.value = value
	end

	txt.formats		= formats

	Add(txt)
	return txt
end

-- Box made of stroke lines

-- made by four lines
line_box_indices		= {0, 1, 1, 2, 2, 3, 3, 0}

function addStrokeBox(name, sideX, sideY, align, pos, parent, controllers, material)
	local box		= CreateElement "ceSMultiLine"
	setSymbolCommonProperties(box, name, pos, parent, controllers, material)
	setSymbolAlignment(box, align)
	setStrokeSymbolProperties(box)

	local halfSideX	= sideX / 2
	local halfSideY	= sideY / 2

	if align == "LeftCenter" then
		box.vertices	= {{0, halfSideY}, {2*halfSideX, halfSideY}, {2*halfSideX, -halfSideY}, {0, -halfSideY}}
	elseif align == "RightCenter" then
		box.vertices	= {{-2*halfSideX, halfSideY}, {0, halfSideY}, {0, -halfSideY}, {-2*halfSideX, -halfSideY}}
	elseif align == "CenterTop" then
		box.vertices	= {{-halfSideX, 0}, {halfSideX, 0}, {halfSideX, -2*halfSideY}, {-halfSideX, -2*halfSideY}}
	elseif align == "CenterBottom" then
		box.vertices	= {{-halfSideX, 2*halfSideY}, {halfSideX, 2*halfSideY}, {halfSideX, 0}, {-halfSideX, 0}}
	else 
		box.vertices	= {{-halfSideX, halfSideY}, {halfSideX, halfSideY}, {halfSideX, -halfSideY}, {-halfSideX, -halfSideY}}
	end
	box.indices		= line_box_indices

	Add(box)
	return box
end

function addFillBox(name, sideX, sideY, align, pos, parent, controllers, material)
	local box		= CreateElement "ceMeshPoly"
	setSymbolCommonProperties(box, name, pos, parent, controllers, material)
	setSymbolAlignment(box, align)

	local halfSideX	= sideX / 2
	local halfSideY	= sideY / 2
	if align == "LeftCenter" then
		box.vertices	= {{0, halfSideY}, {2*halfSideX, halfSideY}, {2*halfSideX, -halfSideY}, {0, -halfSideY}}
	elseif align == "RightCenter" then
		box.vertices	= {{-2*halfSideX, halfSideY}, {0, halfSideY}, {0, -halfSideY}, {-2*halfSideX, -halfSideY}}
	elseif align == "CenterTop" then
		box.vertices	= {{-halfSideX, 0}, {halfSideX, 0}, {halfSideX, -2*halfSideY}, {-halfSideX, -2*halfSideY}}
	elseif align == "CenterBottom" then
		box.vertices	= {{-halfSideX, 2*halfSideY}, {halfSideX, 2*halfSideY}, {halfSideX, 0}, {-halfSideX, 0}}
	else 
		box.vertices	= {{-halfSideX, halfSideY}, {halfSideX, halfSideY}, {halfSideX, -halfSideY}, {-halfSideX, -halfSideY}}
	end
	box.indices		= default_box_indices

	Add(box)
	return box
end

function addFillArrowBox(name, sideX, sideY, align, pos, parent, controllers, material)
	local box		= CreateElement "ceMeshPoly"
	setSymbolCommonProperties(box, name, pos, parent, controllers, material)
	setSymbolAlignment(box, align)

	local halfSideX	= sideX / 2
	local halfSideY	= sideY / 2
    box.primitivetype = "triangles"
    box.vertices	= {{-halfSideX, 0}, {-halfSideX + 1.5 * halfSideY, halfSideY}, {halfSideX, halfSideY}, {halfSideX, -halfSideY}, {-halfSideX + 1.5 * halfSideY, -halfSideY}}
    box.indices = {0, 1, 2, 0, 2, 3, 0, 3, 4}
	Add(box)
	return box
end

-- Stroke line
-- rot (CCW in degrees from up)
-- pos (position of beginning of the line)
function addStrokeLine(name, length, pos, rot, parent, controllers, dashed, stroke, gap, material)
	local line		= CreateElement "ceSMultiLine"
	setSymbolCommonProperties(line, name, pos, parent, controllers, material)
	setStrokeSymbolProperties(line)

	if rot ~= nil then
		line.init_rot	= {rot}
	end

	local verts, inds = buildStrokeLineVerts(length, dashed, stroke, gap)
	line.vertices	= verts
	line.indices	= inds

	Add(line)
	return line
end

function addSimpleLine(name, length, pos, rot, parent, controllers, width, material)
	local line		= CreateElement "ceSimpleLineObject"
	setSymbolCommonProperties(line, name, pos, parent, controllers, material)
	line.width = width or 1

	if rot ~= nil then
		line.init_rot	= {rot}
	end

	local verts = buildStrokeLineVerts(length, nil, nil, nil)
	line.vertices	= verts
	line.tex_params     = {{0, 0.5}, {1, 0.5}, {1 / (1024 * 100 / 275), 1}}

	Add(line)
	return line
end

-- Stroke circle
function addStrokeCircle(name, radius, pos, parent, controllers, arc, segment, gap, dashed, material)
	local segmentsN = 64

	local circle			= CreateElement "ceSCircle"
	setSymbolCommonProperties(circle, name, pos, parent, controllers, material)
	setStrokeSymbolProperties(circle)
	circle.radius			= {radius, radius}
	circle.arc				= arc or {0, math.pi * 2}
	circle.segment			= segment or math.pi * 4 / segmentsN
	circle.gap				= gap or math.pi * 4 / segmentsN
	circle.segment_detail	= 4

	if dashed ~= nil then
		circle.dashed		= dashed
	else
		circle.dashed		= false
	end

	Add(circle)
	return circle
end


-- Stroke circle
function addStrokeCircleBox(name, radius, pos, parent, controllers, arc, segment, gap, dashed, material)
	local segmentsN = 64

	local circle			= CreateElement "ceSMultiLine"
	setSymbolCommonProperties(circle, name, pos, parent, controllers, material)
	setStrokeSymbolProperties(circle)



    local verts = {}
    local arc_s = arc[1]
    local arc_step = (arc[2]-arc[1])/(segmentsN-1)
    local inds = {}

    for i=1, segmentsN do
        verts[i] = {radius * math.cos(arc_s), radius * math.sin(arc_s)}

        arc_s = arc_s + arc_step
        if i < segmentsN then 
            inds[2*i-1] = i-1
            inds[2*i] = i
        end
    end
    radius = radius * math.sqrt(2) /2

    inds[#inds+1] = #verts-1
    inds[#inds+1] = #verts
    verts[#verts+1] = {-radius, -radius}
    inds[#inds+1] = #verts-1
    inds[#inds+1] = #verts
    verts[#verts+1] = {radius, -radius}
    inds[#inds+1] = #verts-1
    inds[#inds+1] = 0

    circle.vertices = verts
    circle.indices = inds

    -- circle.vertices	= {{-radius, -radius}, {-radius, radius}, {radius, radius}, {radius, -radius}}
	-- circle.indices		= line_box_indices

	Add(circle)
	return circle
end

function addMeshCircleBox(name, radius, pos, parent, controllers, arc, segment, gap, dashed, material)
	local segmentsN = 64

	local circle			= CreateElement "ceMeshPoly"
	setSymbolCommonProperties(circle, name, pos, parent, controllers, material)
	setStrokeSymbolProperties(circle)

    circle.primitivetype = "triangles"

    local verts = {}
    local arc_s = arc[1]
    local arc_step = (arc[2]-arc[1])/(segmentsN-1)
    local inds = {}

    for i=1, segmentsN do
        verts[i] = {radius * math.cos(arc_s), radius * math.sin(arc_s)}

        arc_s = arc_s + arc_step
        if i>=3 and i <= segmentsN then 
            inds[3*(i-3)+1] = 0
            inds[3*(i-3)+2] = i-2
            inds[3*(i-3)+3] = i-1
        end
    end
    radius = radius * math.sqrt(2) /2

    inds[#inds+1] = 0
    inds[#inds+1] = #verts-1
    inds[#inds+1] = #verts
    verts[#verts+1] = {-radius, -radius}
    inds[#inds+1] = 0
    inds[#inds+1] = #verts-1
    inds[#inds+1] = #verts
    verts[#verts+1] = {radius, -radius}

    circle.vertices = verts
    circle.indices = inds

    -- circle.vertices	= {{-radius, -radius}, {-radius, radius}, {radius, radius}, {radius, -radius}}
	-- circle.indices		= line_box_indices

	Add(circle)
	return circle
end


function SetCircleMesh(obj, radius_outer, radius_inner, iarc, iclipped)
    local verts    = {}
    local inds     = {}
    local solid    = radius_inner == nil or radius_inner == 0
    local arc      = iarc or 360
    local count    = 36
    local delta    = math.rad(arc/count)
    local clipped  = iclipped or false
    
    if arc > 360 or arc < 0 then
        arc = 360
    end

    local min_i    = 1
    local max_i    = count + 1
    verts[1] = {0,0}
    for i=min_i,max_i do
        k = i
        
        ---- for ADI clipped ball shape
        -- clip nodes are 3 from each side
        if clipped then
            if i < 4 or i > 34 then -- equal to 3, 33
                k = 4
            elseif i > 16 and i < 22 then -- equal to 15, 21
                k = 16
            end
        end
        
        if solid then
            verts[1 + i]      = { radius_outer * math.cos(delta *(k-1)), radius_outer * math.sin(delta *(k-1)), }
            inds[3*(i-1) + 1] = 0
            inds[3*(i-1) + 2] = i - 1 
            inds[3*(i-1) + 3] = i 
        else
            verts[2*(i - 1) + 1] = { radius_outer * math.cos(delta *(k-1)), radius_outer * math.sin(delta *(k-1)), }
            verts[2*(i - 1) + 2] = { radius_inner * math.cos(delta *(k-1)), radius_inner * math.sin(delta *(k-1)), }
            
            if i == max_i  then
              if arc == 360 then  
                inds[6*(i-1) + 1] = 2*(i     - 1)
                inds[6*(i-1) + 2] = 2*(min_i - 1)
                inds[6*(i-1) + 3] = 2*(i     - 1) + 1 
                inds[6*(i-1) + 4] = 2*(i     - 1) + 1
                inds[6*(i-1) + 5] = 2*(min_i - 1)
                inds[6*(i-1) + 6] = 2*(min_i - 1) + 1 
              end        
            else 
                inds[6*(i-1) + 1] = 2*(i - 1)
                inds[6*(i-1) + 2] = 2*(i) 
                inds[6*(i-1) + 3] = 2*(i - 1) + 1 
                inds[6*(i-1) + 4] = 2*(i - 1) + 1
                inds[6*(i-1) + 5] = 2*(i) 
                inds[6*(i-1) + 6] = 2*(i)     + 1  
            end
        end
    end
    obj.vertices = verts              
    obj.indices  = inds
end

function SetCircleMeshStartEnd(obj, radius_outer, radius_inner, istart, iarc, iclipped)
    local verts    = {}
    local inds     = {}
    local solid    = radius_inner == nil or radius_inner == 0
    local arc      = iarc or 360
    local count    = 36
    local delta    = math.rad(arc/count)
    local start    = math.rad(istart or 0)
    local clipped  = iclipped or false
    
    if arc > 360 or arc < -360 then
        arc = 360
    end

    local min_i    = 1
    local max_i    = count + 1
    verts[1] = {0,0}
    for i=min_i,max_i do
        k = i
        
        ---- for ADI clipped ball shape
        -- clip nodes are 3 from each side
        if clipped then
            if i < 4 or i > 34 then -- equal to 3, 33
                k = 4
            elseif i > 16 and i < 22 then -- equal to 15, 21
                k = 16
            end
        end
        
        if solid then
            verts[1 + i]      = { radius_outer * math.cos(start+delta *(k-1)), radius_outer * math.sin(start+delta *(k-1)), }
            inds[3*(i-1) + 1] = 0
            inds[3*(i-1) + 2] = i - 1 
            inds[3*(i-1) + 3] = i 
        else
            verts[2*(i - 1) + 1] = { radius_outer * math.cos(start+delta *(k-1)), radius_outer * math.sin(start+delta *(k-1)), }
            verts[2*(i - 1) + 2] = { radius_inner * math.cos(start+delta *(k-1)), radius_inner * math.sin(start+delta *(k-1)), }
            
            if i == max_i  then
              if arc == 360 then  
                inds[6*(i-1) + 1] = 2*(i     - 1)
                inds[6*(i-1) + 2] = 2*(min_i - 1)
                inds[6*(i-1) + 3] = 2*(i     - 1) + 1 
                inds[6*(i-1) + 4] = 2*(i     - 1) + 1
                inds[6*(i-1) + 5] = 2*(min_i - 1)
                inds[6*(i-1) + 6] = 2*(min_i - 1) + 1 
              end        
            else 
                inds[6*(i-1) + 1] = 2*(i - 1)
                inds[6*(i-1) + 2] = 2*(i) 
                inds[6*(i-1) + 3] = 2*(i - 1) + 1 
                inds[6*(i-1) + 4] = 2*(i - 1) + 1
                inds[6*(i-1) + 5] = 2*(i) 
                inds[6*(i-1) + 6] = 2*(i)     + 1  
            end
        end
    end
    obj.vertices = verts              
    obj.indices  = inds
end

function addMesh(name, vertices, indices, pos, primitives, parent, controllers, material)
	local mesh				= CreateElement "ceMeshPoly"
	setSymbolCommonProperties(mesh, name, pos, parent, controllers, material)
	mesh.vertices			= vertices or {}
	mesh.indices			= indices or {}
	mesh.primitivetype		= primitives
	Add(mesh)
	return mesh
end
local aspect = GetAspect()

local OSSPos = {
	{-0.714285714, aspect* 0.96},
	{-0.42, aspect* 0.96},
	{-0.142857143, aspect* 0.96},
	{0.142857143, aspect* 0.96},
	{0.42, aspect* 0.96},
	{0.714285714, aspect* 0.96},
	{0.975, ( 5.85*1.0/8) * aspect},
	{0.975, ( 4.35*1.0/8) * aspect},
	{0.975, ( 2.55*1.0/8) * aspect},
	{0.975, ( 0.9*1.0/8) * aspect},
	{0.975, (-1.2*1.0/8) * aspect},
	{0.975, (-2.8*1.0/8) * aspect},
	{0.975, (-4.5*1.0/8) * aspect},
	{0.975, (-6.1*1.0/8) * aspect},
	{0.714285714, -aspect* 0.96},
	{0.42, -aspect* 0.96},
	{0.142857143, -aspect* 0.96},
	{-0.142857143, -aspect* 0.96},
	{-0.42, -aspect* 0.96},
	{-0.714285714, -aspect* 0.96},
	{-0.975, (-6.1*1.0/8) * aspect},
	{-0.975, (-4.5*1.0/8) * aspect},
	{-0.975, (-2.8*1.0/8) * aspect},
	{-0.975, (-1.2*1.0/8) * aspect},
	{-0.975, ( 0.9*1.0/8) * aspect},
	{-0.975, ( 2.55*1.0/8) * aspect},
	{-0.975, ( 4.35*1.0/8) * aspect},
	{-0.975, ( 5.85*1.0/8) * aspect},


}

function addOSSText(ossnum, value, parent, parameters, controllers, formats)
	local align
	if ossnum <= 6 then
		align = "CenterTop"
	elseif ossnum <= 14  then
		align = "RightCenter"
	elseif ossnum <= 20  then
		align = "CenterBottom"
	else
		align = "LeftCenter"
	end
	local object = addStrokeText(nil, value or "", CMFD_STRINGDEFS_DEF_X08, align, OSSPos[ossnum], parent, controllers, formats)
	if parameters ~= nil then object.element_params = parameters end
	if controllers ~= nil then	object.controllers = controllers end
	if formats ~= nil then	object.formats = formats end
	return object
end

function addOSSBlinkingText(ossnum, value, parent, parameters, controllers, formats)
	local align
	if ossnum <= 6 then
		align = "CenterTop"
	elseif ossnum <= 14  then
		align = "RightCenter"
	elseif ossnum <= 20  then
		align = "CenterBottom"
	else
		align = "LeftCenter"
	end
	local object = addStrokeText(nil, value or "", CMFD_STRINGDEFS_DEF_X08, align, OSSPos[ossnum], parent, controllers, formats)
	if parameters ~= nil then object.element_params = parameters end
	if controllers ~= nil then	object.controllers = controllers end
	if formats ~= nil then	object.formats = formats end
	return object
end

function addOSSStrokeBox(ossnum, lines, parent, parameters, controllers, material, length)
	lines = lines or 1
	length = length or 8
	local align
	if ossnum <= 6 then
		align = "CenterTop"
	elseif ossnum <= 14  then
		align = "RightCenter"
	elseif ossnum <= 20  then
		align = "CenterBottom"
	else
		align = "LeftCenter"
	end
	local object = addStrokeBox(nil, 0.0375 * length, 0.064 * lines, align, OSSPos[ossnum], parent, controllers, material)
	if parameters ~= nil then object.element_params = parameters end
	if controllers ~= nil then	object.controllers = controllers end
	return object
end

function addStrokeBoxDashed(name, sideX, sideY, stroke, gap, pos, parent, controllers, material)
	local root = addPlaceholder(name, pos, parent, controllers)
	addStrokeLine(root.name.."_left", sideY, {-sideX / 2, -sideY / 2}, 0, root.name, nil, true, stroke, gap, material)
	addStrokeLine(root.name.."_right", sideY, {sideX / 2, -sideY / 2}, 0, root.name, nil, true, stroke, gap, material)
	addStrokeLine(root.name.."_top", sideX, {-sideX / 2, sideY / 2}, -90, root.name, nil, true, stroke, gap, material)
	addStrokeLine(root.name.."_bottom", sideX, {-sideX / 2, -sideY / 2}, -90, root.name, nil, true, stroke, gap, material)
	return root
end

function addOSSArrow(ossnum, up_direction, parent, parameters, controllers, material)
	local origin = OSSPos[ossnum]
	if ossnum <= 6 then
		origin[2] = origin[2] - 0.085
	elseif ossnum <= 14  then
		origin[1] = origin[1] - 0.085
	elseif ossnum <= 20  then
	else
		origin[1] = origin[1] + 0.085
	end
	local object = addStrokeLine(nil, 0.0, origin, 0, parent, controllers, nil, nil, nil, material)
	object.vertices = {{0,0.03}, {0.06, -0.03}, {-0.06, -0.03}}
	object.indices = {0,1, 1,2, 2,0}

	if up_direction == 0 then
		object.init_rot = {180}
	else 
		object.init_rot = {0}
	end

	if parameters ~= nil then object.element_params = parameters end
	if controllers ~= nil then	object.controllers = controllers end
	return object
end

function SetMeshCircle(object, radius, numpts)

    local verts = {}
    local inds = {}

    step = math.rad(360.0/numpts)
    for i = 1, numpts do
        verts[i] = {radius * math.cos(i * step), radius * math.sin(i * step)}
    end
    j = 0
    for i = 0, numpts-3 do
        j = j + 1
        inds[j] = 0
        j = j + 1
        inds[j] = i + 1
        j = j + 1
        inds[j] = i + 2
    end

    object.vertices = verts
    object.indices  = inds
    return object
end