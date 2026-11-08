extends Node3D

const BREAKUP_DURATION = 4.0

func start(source: Node3D):
    var hull = find_largest_mesh(source)
    if hull == null or !(hull.mesh is ArrayMesh):
        queue_free()
        return

    var source_mesh: ArrayMesh = hull.mesh
    var start_transform = hull.global_transform
    var surface_count = source_mesh.get_surface_count()

    for surface_index in range(surface_count):
        var fragment_mesh = ArrayMesh.new()
        fragment_mesh.add_surface_from_arrays(
            source_mesh.surface_get_primitive_type(surface_index),
            source_mesh.surface_get_arrays(surface_index)
        )
        var surface_material = hull.get_active_material(surface_index)
        var death_light_material: StandardMaterial3D = null
        if is_death_light_material(surface_material):
            death_light_material = surface_material.duplicate()
            surface_material = death_light_material
        fragment_mesh.surface_set_material(0, surface_material)

        var fragment = MeshInstance3D.new()
        fragment.mesh = fragment_mesh
        add_child(fragment)
        fragment.global_transform = start_transform
        animate_fragment(fragment, surface_index, surface_count)
        if death_light_material:
            fade_death_light(death_light_material)

    play_internal_explosions(source.global_position)
    get_tree().create_timer(BREAKUP_DURATION).timeout.connect(queue_free)

func find_largest_mesh(root: Node) -> MeshInstance3D:
    var largest_mesh: MeshInstance3D
    var largest_vertex_count = 0

    for child in get_all_children(root):
        if child is MeshInstance3D and child.mesh is ArrayMesh:
            var vertex_count = 0
            for surface_index in range(child.mesh.get_surface_count()):
                var arrays = child.mesh.surface_get_arrays(surface_index)
                var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
                vertex_count += vertices.size()

            if vertex_count > largest_vertex_count:
                largest_vertex_count = vertex_count
                largest_mesh = child

    return largest_mesh

func get_all_children(root: Node) -> Array[Node]:
    var children: Array[Node] = []
    for child in root.get_children():
        children.append(child)
        children.append_array(get_all_children(child))
    return children

func is_death_light_material(material: Material) -> bool:
    return (
        material is StandardMaterial3D
        and material.emission_enabled
        and material.emission_energy_multiplier > 1.0
    )

func fade_death_light(material: StandardMaterial3D):
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

    var transparent_albedo = material.albedo_color
    transparent_albedo.a = 0.0
    var transparent_emission = material.emission
    transparent_emission.a = 0.0

    var tween = create_tween()
    tween.tween_property(material, "emission_energy_multiplier", 0.0, 0.5)
    tween.parallel().tween_property(material, "albedo_color", transparent_albedo, 0.5)
    tween.parallel().tween_property(material, "emission", transparent_emission, 0.5)

func animate_fragment(fragment: MeshInstance3D, index: int, count: int):
    var centered_index = index - (count - 1) / 2.0
    var direction = Vector3(
        randf_range(-3.0, 4.0),
        centered_index * 8.0 + randf_range(-3.0, 3.0),
        randf_range(-10.0, 10.0)
    )
    var rotation_target = fragment.rotation_degrees + Vector3(
        randf_range(-180.0, 180.0),
        randf_range(-240.0, 240.0),
        randf_range(-180.0, 180.0)
    )

    var tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(fragment, "global_position", fragment.global_position + direction, BREAKUP_DURATION)
    tween.parallel().tween_property(fragment, "rotation_degrees", rotation_target, BREAKUP_DURATION)
    tween.parallel().tween_property(fragment, "scale", fragment.scale * 0.45, BREAKUP_DURATION)

func play_internal_explosions(origin: Vector3):
    var offsets = [
        Vector3(0, -7, -3),
        Vector3(1, 5, 5),
        Vector3(-2, 0, -8),
    ]

    for offset in offsets:
        Globals.explode(origin + offset, 2, 2)
        await get_tree().create_timer(0.18).timeout
