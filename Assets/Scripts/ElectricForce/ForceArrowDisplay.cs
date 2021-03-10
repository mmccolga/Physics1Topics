using System;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
///     ForceArrowDisplay class. Generates a custom arrow mesh based on a Position and Direction vectors.
///     Needs to attached to an object with a MeshFilter component (ex. A 3d object)
/// </summary>
public class ForceArrowDisplay : MonoBehaviour
{
    // Just some static constants
    public const float BodyHeightScaleFactor = 0.4f;
    public const float HeadHeightScaleFactor = BodyHeightScaleFactor;
    public const float RadiusScaleFactor = 1f;
    private const float DefaultRadius = .1f;
    private const float RadiusBodyFactor = 0.707107f;
    private const float RadiusHeadFactor = 1.6f;


    private float BodyHeight = 1f;

    // Direction of the arrow. The magnitude of the Direction is important because it defines te arrows length.
    public Vector3 Direction;
    private float HeadHeight = 1f;

    // The origin position of arrow
    public Vector3 Position;


    private float Radius = DefaultRadius;


    /// <summary>
    ///     Get the arrow body vertices.
    /// </summary>
    private Vector3[] BodyVerts =>
        new[]
        {
            new Vector3(0, -0, 0),
            new Vector3(0, BodyHeight, 0),
            new Vector3(0, -0, -Radius),
            new Vector3(0, BodyHeight, -Radius),
            new Vector3(Radius * RadiusBodyFactor, -0, -Radius * RadiusBodyFactor),
            new Vector3(Radius * RadiusBodyFactor, BodyHeight, -Radius * RadiusBodyFactor),
            new Vector3(Radius, -0, 0),
            new Vector3(Radius, BodyHeight, 0),
            new Vector3(Radius * RadiusBodyFactor, -0, Radius * RadiusBodyFactor),
            new Vector3(Radius * RadiusBodyFactor, BodyHeight, Radius * RadiusBodyFactor),
            new Vector3(-0, -0, Radius),
            new Vector3(-0, BodyHeight, Radius),
            new Vector3(-Radius * RadiusBodyFactor, -0, Radius * RadiusBodyFactor),
            new Vector3(-Radius * RadiusBodyFactor, BodyHeight, Radius * RadiusBodyFactor),
            new Vector3(-Radius, -0, -0),
            new Vector3(-Radius, BodyHeight, -0),
            new Vector3(-Radius * RadiusBodyFactor, -0, -Radius * RadiusBodyFactor),
            new Vector3(-Radius * RadiusBodyFactor, BodyHeight, -Radius * RadiusBodyFactor)
        };

    /// <summary>
    ///     Get the arrow body indices.
    /// </summary>
    private int[] BodyInds =>
        new[]
        {
            0, 2, 4,
            1, 5, 3,
            3, 4, 2,
            0, 4, 6,
            1, 7, 5,
            5, 6, 4,
            0, 6, 8,
            1, 9, 7,
            7, 8, 6,
            0, 8, 10,
            1, 11, 9,
            9, 10, 8,
            0, 10, 12,
            1, 13, 11,
            11, 12, 10,
            0, 12, 14,
            1, 15, 13,
            13, 14, 12,
            0, 14, 16,
            1, 17, 15,
            15, 16, 14,
            0, 16, 2,
            1, 3, 17,
            17, 2, 16,
            3, 5, 4,
            5, 7, 6,
            7, 9, 8,
            9, 11, 10,
            11, 13, 12,
            13, 15, 14,
            15, 17, 16,
            17, 3, 2
        };


    /// <summary>
    ///     Get the arrow head vertices.
    /// </summary>
    private Vector3[] HeadVerts =>
        new[]
        {
            new Vector3(0f, BodyHeight, -RadiusHeadFactor * Radius),

            new Vector3(RadiusBodyFactor * RadiusHeadFactor * Radius, BodyHeight,
                -RadiusBodyFactor * RadiusHeadFactor * Radius),

            new Vector3(RadiusHeadFactor * Radius, BodyHeight, 0f),

            new Vector3(RadiusBodyFactor * RadiusHeadFactor * Radius, BodyHeight,
                RadiusBodyFactor * RadiusHeadFactor * Radius),

            new Vector3(-0f, BodyHeight, RadiusHeadFactor * Radius),

            new Vector3(-RadiusBodyFactor * RadiusHeadFactor * Radius, BodyHeight,
                RadiusBodyFactor * RadiusHeadFactor * Radius),

            new Vector3(-RadiusHeadFactor * Radius, BodyHeight, -0f),

            new Vector3(-RadiusBodyFactor * RadiusHeadFactor * Radius, BodyHeight,
                -RadiusBodyFactor * RadiusHeadFactor * Radius),

            new Vector3(-0f, BodyHeight + HeadHeight, -0f),

            new Vector3(-0f, BodyHeight, -0f)
        };

    /// <summary>
    ///     Get the arrow head indices.
    /// </summary>
    private static int[] HeadInds =>
        new[]
        {
            0, 7, 8,
            6, 5, 8,
            4, 3, 8,
            2, 1, 8,
            7, 6, 8,
            5, 4, 8,
            3, 2, 8,
            1, 0, 8,
            1, 2, 9,
            6, 7, 9,
            4, 5, 9,
            2, 3, 9,
            0, 1, 9,
            7, 0, 9,
            5, 6, 9,
            3, 4, 9
        };

    private static Vector3 BaseDirection { get; } = new Vector3(0, 1, 0);


    // Start is called before the first frame update
    private void Start()
    {
    }

    // Update is called once per frame
    private void Update()
    {
        var mf = GetComponent<MeshFilter>();
        var mag = Direction.magnitude;


        BodyHeight = Math.Abs(mag - 1) * ChargedParticle.ScaleFactor * BodyHeightScaleFactor;
        HeadHeight = ChargedParticle.ScaleFactor * HeadHeightScaleFactor;
        Radius = DefaultRadius * ChargedParticle.ScaleFactor * RadiusScaleFactor;

        mf.mesh.triangles = GetAllIndices(); // Setting indices array first, because  otherwise, Unity throws errors.
        mf.mesh.vertices = GetAllVertices();
        mf.mesh.RecalculateNormals();
        SetupProperRotation();
        SetupProperPosition();
        mf.mesh.RecalculateBounds();

        // Debug.Log("Arrow Center: " + mf.mesh.bounds.center);
    }

    private void SetupProperRotation()
    {
        GetComponent<Transform>().localRotation = Quaternion.FromToRotation(BaseDirection, Direction);
    }

    private void SetupProperPosition()
    {
        GetComponent<Transform>().localPosition = Position;
    }

    private Vector3[] GetAllVertices()
    {
        var ls = new List<Vector3>(BodyVerts.Length + HeadVerts.Length);
        foreach (var vert in BodyVerts) ls.Add(vert);

        foreach (var vert in HeadVerts) ls.Add(vert);

        return ls.ToArray();
    }


    private int[] GetAllIndices()
    {
        var ls = new List<int>(BodyInds.Length + HeadInds.Length);
        foreach (var ind in BodyInds) ls.Add(ind);

        foreach (var ind in HeadInds) ls.Add(ind + BodyVerts.Length);

        return ls.ToArray();
    }
}